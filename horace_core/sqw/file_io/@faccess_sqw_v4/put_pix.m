function   obj = put_pix(obj,varargin)
% Save or replace pixels information within binary sqw file
%
%Usage:
%>>obj = obj.put_pix();
%>>obj = obj.put_pix(sqw_obj);
%>>obj = obj.put_pix(pix_obj);
%
% Optional:
% '-update' -- update existing data rather then (over)writing new file
%             (deprecated, ignored, update occurs automatically if proper file is 
%              provided)
% '-nopix'  -- do not write pixels
% '-reserve' -- if applied together with nopix, pixel information is not
%               written but the space dedicated for pixels is filled in with zeros.
%               If -nopix is not used, the option is ignored.
%
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
    elseif isempty(numeric_pos)
        input_obj = argi{numeric_pos};
    else
        input_obj = obj.sqw_holder_.pix;
    end
else
    input_obj = obj.sqw_holder_.pix;
    jobDispatcher = [];
end
if isnumeric(input_obj)
    num_pixels = size(input_obj,2);
else
    num_pixels = input_obj.num_pixels;
end


if ~(isa(input_obj,'pix_combine_info')|| (~isnumeric(input_obj)&&input_obj.is_filebacked))
    obj = obj.put_sqw_block('bl_pix_metadata',input_obj);
    obj = obj.put_sqw_block('bl_pix_data_wrap',input_obj);
    return;
end
obj = obj.put_sqw_block('bl_pix_metadata',input_obj.metadata);

% get block responsible for writing pix_data
pdb = obj.bat_.blocks_list{end};
if nopix && ~reserve
    pdb.npix = 0;
end
% write pixel data block information; number of dimensions and number of pixels
pdb.put_data_header(obj.file_id_);


% write pixels themselves
try
    do_fseek(obj.file_id_,obj.pix_position,'bof');
catch ME
    exc = MException('HORACE:put_pix:io_error',...
        'Error moving to the start of the pixels info');
    throw(exc.addCause(ME))
end

if nopix && reserve
    block_size= config_store.instance().get_value('hor_config','mem_chunk_size'); % size of buffer to hold pixel information

    if block_size >= num_pixels
        res_data = single(zeros(9,num_pixels));
        fwrite(obj.file_id_,res_data,'float32');
    else
        written = 0;
        res_data = single(zeros(9,block_size));
        while written < num_pixels
            fwrite(obj.file_id_,res_data,'float32');
            written = written+block_size;
            if written+block_size > num_pixels
                block_size = num_pixels-written;
                res_data = single(zeros(9,block_size));
            end
        end
    end
    clear res_data;
    return;
end

if num_pixels == 0
    return % nothing to do.
end
%
if isa(input_obj,'pix_combine_info') % pix field contains info to read &
    %combine pixels from sequence of files. There is special sub-algorithm
    %to do that.
    obj = obj.put_sqw_data_pix_from_file(input_obj, jobDispatcher);
elseif isa(input_obj,'PixelDataBase')  % write pixels stored in other file

    n_pages = input_obj.num_pages;
    for i = 1:n_pages
        input_obj.page_num = i;
        pix_data = input_obj.get_pixels('-keep_precision','-raw_data');
        try
            fwrite(obj.file_id_, single(pix_data), 'float32');
            obj.check_write_error(obj.file_id_);
        catch ME
            exc = MException('HORACE:put_pix:io_error',...
                sprintf('Error writing input pixels for page N%d out of %d',i,n_pages));
            throw(exc.addCause(ME))
        end

    end
else % pixel data array. As it is in memory, write it as a sigle block
    fwrite(obj.file_id_, single(input_obj), 'float32');
    obj.check_write_error(obj.file_id_);
end
