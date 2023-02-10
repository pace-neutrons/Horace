function   obj = put_pix(obj,varargin)
% Save or replace pixels information within binary sqw file
%
%Usage:
%>>obj = obj.put_pix();
% Availible options:
% '-update' -- update eixsting data rather then (over)writing new file
% '-nopix'  -- do not write pixels
% '-reserve' -- if applied together with nopix, pixel information is not
%               written but the space dedicated for pixels is filled in with zeros.
%                If -nopix is not used, the option is ignored.
%
% If update options is selected, file header have to exist. This option keeps
% exisitng file information untouched;
[ok,mess,update,nopix,reserve,argi] = parse_char_options(varargin,{'-update','-nopix','-reserve'});
if ~ok
    error('SQW_FILE_IO:invalid_argument',...
        'SQW_BINFILE_COMMON::put_pix: %s',mess);
end

if ~obj.is_activated('write')
    obj = obj.activate('write');
end

obj.check_obj_initated_properly();


if ~isempty(argi) % parse inputs which may or may not contain any
    % combination of 3 following input parameters:
    sqw_pos = cellfun(@(x)(isa(x,'sqw')||isstruct(x)),argi);
    numeric_pos = cellfun(@isnumeric,argi);
    parallel_Fw = cellfun(@(x)isa(x,'JobDispatcher'),argi);
    %
    unknown  = ~(sqw_pos|numeric_pos|parallel_Fw);
    if any(unknown)
        disp('unknown input: ',argi{unknown});
        error('SQW_BINFILE_COMMON:invalid_argument',...
            'put_pixel: the routine accepts only sqw object and/or low and high numbers for pixels to save');
    end

    if any(parallel_Fw)
        jobDispatcher = argi{parallel_Fw};
    else
        jobDispatcher  = [];
    end

    if any(sqw_pos)
        input_obj = argi{sqw_pos};
    else
        input_obj = [];
    end

    if ~isempty(input_obj)
        if isa(input_obj,'sqw')
            input_obj = input_obj.data;
        end
        update = true;
    else
        input_obj = obj.sqw_holder_.data;
    end
else
    input_obj = obj.sqw_holder_.data;
    input_num = [];
    jobDispatcher = [];
end


head_pix_format = obj.get_data_form('-pix_only');
if update
    if ~obj.upgrade_mode
        error('SQW_FILE_IO:runtime_error',...
            'SQW_BINFILE_COMMON::put_pix: input object has not been initiated for update mode');
    end
    if ~nopix && (obj.npixels ~= input_obj.pix.num_pixels)
        error('SQW_FILE_IO:runtime_error',...
            'SQW_BINFILE_COMMON::put_pix: unable to update pixels and pix number in file and update are different');
    end
    val   = obj.upgrade_map_.cblocks_map('pix');
    start_pos = val(1);
else
    start_pos = obj.img_db_range_pos_;
end
% Here we handle the issue with the old data format
% sqw_dnd_data contains img_db_range and pix contains pix_range. We save only
% pix_range:
%
% % redefine formatter and remove pix_data fields not intended for serialization
 head_pix_format = struct('img_db_range',head_pix_format.img_db_range,...
     'dummy',head_pix_format.dummy);
%
bytes = obj.sqw_serializer_.serialize(input_obj,head_pix_format);


fseek(obj.file_id_,start_pos ,'bof');
check_error_report_fail_(obj,'Error moving to the start of the pixels info');
fwrite(obj.file_id_,bytes,'uint8');
check_error_report_fail_(obj,'Error writing the pixels information');
%
if isa(input_obj.pix,'pix_combine_info')
    npix = input_obj.pix.num_pixels;
else
    npix = input_obj.pix.num_pixels;
end
fwrite(obj.file_id_,npix,'uint64');
%
obj.eof_pix_pos_ = obj.pix_pos_ + npix * 9*4;
if nopix
    if reserve
        block_size= config_store.instance().get_value('hor_config','mem_chunk_size'); % size of buffer to hold pixel information

        fseek(obj.file_id_,obj.pix_pos_ ,'bof');
        if block_size >= npix
            res_data = single(zeros(9,npix));
            fwrite(obj.file_id_,res_data,'float32');
        else
            written = 0;
            res_data = single(zeros(9,block_size));
            while written < npix
                fwrite(obj.file_id_,res_data,'float32');
                written = written+block_size;
                if written+block_size > npix
                    block_size = npix-written;
                    res_data = single(zeros(9,block_size));
                end
            end
        end
        clear res_data;

    else %TODO: Copied from prototype. Does this make any sense?
        fseek(obj.file_id_,obj.eof_pix_pos_ ,'bof');
        ferror(obj.file_id_, 'clear'); % clear error in case if pixels have never been written
    end
    return;
end

if npix == 0
    return % nothing to do.
end
%
if isa(input_obj.pix,'pix_combine_info') % pix field contains info to read &
    %combine pixels from sequence of files. There is special sub-algorithm
    %to do that.
    obj = put_sqw_data_pix_from_file_(obj,input_obj.pix, jobDispatcher);
else % write pixels directly

    % Try writing large array of pixel information a block at a time - seems to speed up the write slightly
    % Need a flag to indicate if pixels are written or not, as cannot rely just on npixtot - we really
    % could have no pixels because none contributed to the given data range.
    block_size = config_store.instance().get_value('hor_config','mem_chunk_size'); % size of buffer to hold pixel information

    fseek(obj.file_id_, obj.pix_pos_ , 'bof');
    check_error_report_fail_(obj, 'Error moving to the start of the pixels record');

    npix_to_write = obj.npixels;
    if npix_to_write <= block_size
        input_obj.pix.move_to_first_page();
        fwrite(obj.file_id_, single(input_obj.pix.data), 'float32');
        while input_obj.pix.has_more()
            input_obj.pix.advance();
            fwrite(obj.file_id_, single(input_obj.pix.data), 'float32');
        end
        check_error_report_fail_(obj,'Error writing pixels array');
    else
        for ipix=1:block_size:npix_to_write
            istart = ipix;
            iend   = min(ipix+block_size-1, npix_to_write);
            fwrite(obj.file_id_, single(input_obj.pix.get_pixels(istart:iend).data), 'float32');
            check_error_report_fail_(obj,...
                sprintf('Error writing pixels array, npix from: %d to: %d in the rage from: %d to: %d',...
                istart,iend,1,npix_to_write));
        end
    end
end
