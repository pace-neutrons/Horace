function   obj = put_pix(obj,varargin)
% Save or replace pixels information within binary sqw file
%
%Usage:
%>>obj = obj.put_pix();
%>>obj = obj.put_pix(sqw_obj);
%>>obj = obj.put_pix(pix_obj);
%>>obj = obj.put_pix(pix_obj.data);
%
% Optional:
% '-update' -- update existing data rather then (over)writing new file
%             (deprecated, ignored, update occurs)
% '-nopix'  -- do not write pixels
% '-reserve' -- if applied together with nopix, pixel information is not
%               written but the space dedicated for pixels is filled in with zeros.
%                If -nopix is not used, the option is ignored.
%
% If update options is selected, file header have to exist. This option keeps
% existing file information untouched;
[ok,mess,~,nopix,reserve,argi] = parse_char_options(varargin,{'-update','-nopix','-reserve'});
if ~ok
    error('HORACE:faccess_sqw_v4:invalid_argument',...
        'SQW_BINFILE_COMMON::put_pix: %s',mess);
end

if ~obj.is_activated('write')
    obj = obj.activate('write');
end


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
    else
        input_obj = obj.sqw_holder_.pix;
    end
else
    input_obj = obj.sqw_holder_.pix;
    jobDispatcher = [];
end

obj = obj.put_block_data('bl_pix_metadata',input_obj);
if ~(isa(input_obj,'pix_combine_info')|| input_obj.is_filebacked)
    obj = obj.put_block_data('bl_pix_data_wrap',input_obj);
    return;
elseif ~isnumeric(obj)
    % write pixel data block information
    pdb = obj.bat_.blocks_list{end};
    pdb.put_data_header(obj.file_id_);
end

try
    do_fseek(obj.file_id_,obj.pix_position,'bof');
catch ME
    exc = MException('HORACE:put_pix:io_error',...
        'Error moving to the start of the pixels info');
    throw(exc.addCause(ME))
end

if nopix
    if reserve
        block_size= config_store.instance().get_value('hor_config','mem_chunk_size'); % size of buffer to hold pixel information

        do_fseek(obj.file_id_,obj.pix_position ,'bof');
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
elseif isa(input_obj,'PixelDataBase')  % write pixels stored in other file

    n_pages = input_obj.num_pages;
    for i = 1:n_pages
        input_obj.page_num = i;
        pix_data = input_obj.get_pixels('-keep_precision','-raw_data');
        fwrite(obj.file_id_, single(pix_data), 'float32');
        check_error_report_fail_(obj,...
            sprintf('Error writing input pixels array for page N%d out of %d',i,n_pages));
    end
else % pixel data array. As it is in memory, write it as a sigle block
    fwrite(obj.file_id_, single(input_obj), 'float32');
    check_error_report_fail_(obj,...
        sprintf('Error writing input pixels array'));
end
