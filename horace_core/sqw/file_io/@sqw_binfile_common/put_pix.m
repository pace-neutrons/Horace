function   obj = put_pix(obj,varargin)
% Save or replace pixels information within binary sqw file
%
%Usage:
%>>obj = obj.put_pix();
% Available options:
% '-update' -- update existing data rather then (over)writing new file
% '-nopix'  -- do not write pixels
% '-reserve' -- if applied together with nopix, pixel information is not
%               written but the space dedicated for pixels is filled in with zeros.
%                If -nopix is not used, the option is ignored.
%
% If update options is selected, file header have to exist. This option keeps
% existing file information untouched;
[ok,mess,update,nopix,reserve,argi] = parse_char_options(varargin,{'-update','-nopix','-reserve'});
if ~ok
    error('SQW_FILE_IO:invalid_argument',...
        'SQW_BINFILE_COMMON::put_pix: %s',mess);
end

if ~obj.is_activated('write')
    obj = obj.activate('write');
end

obj=obj.check_obj_initated_properly();


if ~isempty(argi) % parse inputs which may or may not contain any
    % combination of 3 following input parameters:
    sqw_pos = cellfun(@(x)(isa(x,'sqw')||isstruct(x)),argi);
    numeric_pos = cellfun(@(x)(isnumeric(x)&&~isempty(x)),argi);
    parallel_Fw = cellfun(@(x)isa(x,'JobDispatcher'),argi);
    %
    unknown  = ~(sqw_pos|numeric_pos|parallel_Fw);
    if any(unknown)
        if isempty(argi{1})
            disp('unknown empty input ');
        else
            disp(['unknown input: ',argi{unknown}]);
        end
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
            input_obj = input_obj.pix;
        end
        update = true;
    else
        input_obj = obj.sqw_holder_.pix;
    end
else
    input_obj = obj.sqw_holder_.pix;
    input_num = [];
    jobDispatcher = [];
end


head_pix_format = obj.get_pix_form();
if update
    if ~obj.upgrade_mode
        error('SQW_FILE_IO:runtime_error',...
            'SQW_BINFILE_COMMON::put_pix: input object has not been initiated for update mode');
    end
    if ~nopix && (obj.npixels ~= input_obj.num_pixels)
        error('SQW_FILE_IO:runtime_error',...
            'SQW_BINFILE_COMMON::put_pix: unable to update pixels and pix number in file and update are different');
    end
    val   = obj.upgrade_map_.cblocks_map('pix');
    start_pos = val(1);
else
    start_pos = obj.img_db_range_pos_;
end
%--------------------------------------------------------------------------
% Here we handle the issue with the old data format, and the fact that
% image range is stored in sqw.data field but is written only when pixels
% are written
% % redefine formatter and remove pix_data fields not intended for serialization

head_pix_format = rmfield(head_pix_format,'pix_block');
% Remain oddities from old file format. Pixel part was initially stored in
% data so now when we write pixels, we analyze remaining part of data
data = obj.sqw_holder_.data;
bytes = obj.sqw_serializer_.serialize(data ,head_pix_format);
%--------------------------------------------------------------------------
try
    do_fseek(obj.file_id_,start_pos ,'bof');
catch ME
    exc = MException('COMBINE_SQW_PIX_JOB:io_error',...
                     'Error moving to the start of the pixels info');
    throw(exc.addCause(ME))
end
fwrite(obj.file_id_,bytes,'uint8');
check_error_report_fail_(obj,'Error writing the pixels information');
%
npix = input_obj.num_pixels;

fwrite(obj.file_id_,npix,'uint64');
%
obj.eof_pix_pos_ = obj.pix_pos_ + npix * 9*4;
if nopix
    if reserve
        block_size= config_store.instance().get_value('hor_config','mem_chunk_size'); % size of buffer to hold pixel information

        do_fseek(obj.file_id_,obj.pix_pos_ ,'bof');
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
        try
            do_fseek(obj.file_id_,obj.eof_pix_pos_ ,'bof');
        catch
            ferror(obj.file_id_, 'clear'); % clear error in case if pixels have never been written
        end
    end
    return;
end

if npix == 0
    return % nothing to do.
end
%
if isa(input_obj,'pix_combine_info') % pix field contains info to read &
    %combine pixels from sequence of files. There is special sub-algorithm
    %to do that.
    obj = put_sqw_data_pix_from_file_(obj,input_obj, jobDispatcher);
else % write pixels directly

    % Try writing large array of pixel information a block at a time - seems to speed up the write slightly
    % Need a flag to indicate if pixels are written or not, as cannot rely just on npixtot - we really
    % could have no pixels because none contributed to the given data range.
    block_size = config_store.instance().get_value('hor_config','mem_chunk_size'); % size of buffer to hold pixel information

    try
        do_fseek(obj.file_id_, obj.pix_pos_ , 'bof');
    catch ME
        exc = MException('COMBINE_SQW_PIX_JOB:io_error',...
                         'Error moving to the start of the pixels record');
        throw(exc.addCause(ME))
    end

    npix_to_write = obj.npixels;
    if npix_to_write <= block_size
        input_obj.move_to_first_page();
        fwrite(obj.file_id_, single(input_obj.data), 'float32');
        while input_obj.has_more()
            input_obj.advance();
            fwrite(obj.file_id_, single(input_obj.data), 'float32');
        end
        check_error_report_fail_(obj,'Error writing pixels array');
    else
        for ipix=1:block_size:npix_to_write
            istart = ipix;
            iend   = min(ipix+block_size-1, npix_to_write);
            fwrite(obj.file_id_, single(input_obj.get_pixels(istart:iend).data), 'float32');
            check_error_report_fail_(obj,...
                sprintf('Error writing pixels array, npix from: %d to: %d in the rage from: %d to: %d',...
                istart,iend,1,npix_to_write));
        end
    end
end
