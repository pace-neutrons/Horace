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
% '-hold_pix_place'
%           -- if present, arrange writing pix_metadata and place for pixel
%              data but do not write pixels themselves
%
[ok,mess,~,nopix,reserve,hold_pix_place,argi] = parse_char_options(varargin,{'-update','-nopix','-reserve','-hold_pix_place'});
if ~ok
    error('HORACE:faccess_sqw_v4_1:invalid_argument',...
        'faccess_sqw_v4_1-put_pix: %s',mess);
end

if ~obj.is_activated('write')
    obj = obj.activate('write');
end


if ~isempty(argi) % parse inputs which may or may not contain any
    % combination of 3 following input parameters:
    sqw_pos = cellfun(@(x) isa(x,'sqw') || isstruct(x), argi);
    numeric_pos = cellfun(@(x) isnumeric(x) && ~isempty(x), argi);

    unknown  = ~(sqw_pos|numeric_pos);
    if any(unknown)
        if isempty(argi{1})
            disp('unknown empty input ');
        else
            disp(['unknown input: ',argi{unknown}]);
        end
        error('SQW_BINFILE_COMMON:invalid_argument',...
            'put_pixel: the routine accepts only sqw object and/or low and high numbers for pixels to save');
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
end

if isnumeric(input_obj)
    num_pixels = size(input_obj,2);
else
    num_pixels = input_obj.num_pixels;
end


if ~(isa(input_obj,'MultipixBase') || (~isnumeric(input_obj) && input_obj.is_filebacked))
    obj = obj.put_sqw_block('bl_pix_metadata',input_obj);
    obj = obj.put_sqw_block('bl_pix_data_wrap',input_obj);
    return;
end
metadata = input_obj.metadata;
if metadata.is_corrected
    % Data will be written aligned so metadata should also state that
    % data are aligned. metadata can not grow here, as it will try to place
    % them behind pixels which have not been written yet. And they should
    % not grow.
    metadata.alignment_matr = eye(3);
    obj = obj.put_sqw_block('bl_pix_metadata',metadata);
    % Get pixel data block position to place the block in new place
    % as pixel_metadata probably have changed their size
    % MATLAB SPECIFIC issue, as it can not write behind end of file unless
    % you start writing at the last +1 byte position.
    bat = obj.bat_;
    pdb = bat.blocks_list{end};
    fseek(obj.file_id_,0,'eof');
    real_eof = ftell(obj.file_id_);
    % block position counted from 0
    if pdb.position> real_eof % change
        % position of pixel data block calculated earlier because MATLAB
        % can not write after current EOF.
        for i=1:bat.n_blocks
            bat.blocks_list{i}.locked = true;
        end
        pdb.locked = false;
        bat.blocks_list{end} = pdb;
        bat = bat.clear_unlocked_blocks();
        bat = bat.place_undocked_blocks(input_obj,false);
        bat = bat.put_bat(obj.file_id_);
        for i=1:bat.n_blocks-1
            bat.blocks_list{i}.locked = false;
        end
        pdb = bat.blocks_list{end};
        % lock pixel data block in-place not to move it in a future
        pdb.locked = true;
        bat.blocks_list{end} = pdb;
        obj.bat_ = bat;
    end
else
    obj = obj.put_sqw_block('bl_pix_metadata',metadata);
    % get block responsible for writing pix_data
    pdb = obj.bat_.blocks_list{end};
end
if nopix && ~reserve
    pdb.npix = 0;
end

% write pixel data block information; number of dimensions and number of pixels
pdb.put_data_header(obj.file_id_);
if hold_pix_place
    return;
end


% write pixels themselves
try
    do_fseek(obj.file_id_,obj.pix_position,'bof');
catch ME
    exc = MException('HORACE:put_pix:io_error',...
        'Error moving to the start of the pixels info');
    throw(exc.addCause(ME))
end

if nopix && reserve
    % size of buffer to hold pixel information
    block_size= config_store.instance().get_value('hor_config','mem_chunk_size');

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

if isa(input_obj,'PixelDataBase')  % write pixels stored in other file
    n_pages = input_obj.num_pages;

    % get current position - start point for writing pixel data
    pix_start_A = ftell(obj.file_id_);

    % create null record for number of non-zero signals
    % this will be overwritten after it has been calculated
    totnonzerosigspos=ftell(obj.file_id_);
    total_nonzero_signals = -666; % check value to put in the file
    try
        fwrite(obj.file_id_, single(total_nonzero_signals), 'float32');
        obj.check_write_error(obj.file_id_);
    catch ME
        exc = MException('HORACE:put_pix:io_error',...
            sprintf('Error writing initial non-zero-signal number'));
        throw(exc.addCause(ME))
    end
    total_nonzero_signals = 0; % counter initialization

    % find if the space for the pixels has already been created on file
    % calc size of uncompressed pixel data 
    % (plus space for size of compressed signals etc.)
    pix_size_A = 4*9*input_obj.num_pixels; % pixels only
    % move to end of file and check position
    fseek(obj.file_id_,0,'eof');
    pix_end_A = ftell(obj.file_id_);
    % write zeros if not enough file exists and return
    if (pix_end_A-pix_start_A)<pix_size_A+4 % add extra record size
        % write enough data to fill required space
        blank_data = -44*ones([1,9*input_obj.page_size],'single');
        n_data = 0;
        for ii=1:n_pages-1
            % space for all but one pages of pixels
            fwrite(obj.file_id_, blank_data, 'float32');
            n_data = n_data + input_obj.page_size;
        end
        % space for last page of pixels
        last_page_size = 9*(input_obj.num_pixels-n_data);
        fwrite(obj.file_id_, blank_data(1:last_page_size),'float32');
        % mark the end of pixel data by this route
        pix_end_A = ftell(obj.file_id_);
    else
        % go to end of pixel-sized space
        % there may be more data on file after this
        pix_end_A = pix_start_A + pix_size_A + 4;
        fseek(obj.file_id_, pix_end_A, 'bof');
    end
    % write -999 to mark the end of the uncompressed data
    fwrite(obj.file_id_, -999, 'float32');
    % record the end of main pixel data and return to start of pixel
    % data on file
    pix_end_A = ftell(obj.file_id_);
    % fseek(obj.file_id_, pix_start_A, 'bof');

    % permanent record of location at end of uncompressed data
    % plus the end of uncompressed marker
    endpix2pos = pix_end_A;
    % ****
    % pix_data_3 accumulates all the pix_data_2 here and is used to check
    % the correctness of the function - it is not written out or otherwise
    % used
    % ****
    pix_data_3 = zeros(3,1);
    nonzero_page_sizes = zeros(1,n_pages);
    fseek(obj.file_id_,endpix2pos,'bof'); % end main pixel data
    %fwrite(obj.file_id_, n_pages,'single');
    % page sizes will be filled in after the data is paged through below
    %fwrite(obj.file_id_,nonzero_page_sizes,'single');
    endpix2pos = ftell(obj.file_id_);
    % start paging
    num_pix_to_date = 0;
    fseek(obj.file_id_, pix_start_A+4,'bof');
    curpos = ftell(obj.file_id_);
    for i = 1:n_pages
        % store page number and make it the current page
        input_obj.page_num = i;
        if i==n_pages
            disp(i);
        end
        % get the current page pix data for this pageand its page size
        pix_data = input_obj.data;
        full_page_size = size(pix_data,2);


        % qw = calculate_qw_pixels3(obj.sqw_holder_, ...
        sqt = obj.sqw_holder_;
        ruid_contributed = unique(pix_data(5,:));
        exp_info = sqt.experiment_info.get_subobj(ruid_contributed);
        sqt.experiment_info = exp_info;
        sqt.pix = input_obj;
        qw = calculate_qw_pixels3(sqt, ...            
            pix_data(5,:),pix_data(6,:),pix_data(7,:),false,true);

        % get out the signal and variance components
        sig = pix_data(8,:);
        var = pix_data(9,:);
        % find the positions of the non-zero signals in pix_data(,8)
        % and their values, and the values of their variances
        possig = find(sig);
        possigval = sig(possig);
        posvarval = var(possig);
        % write the positions for the whole file not just this page
        possig = possig + num_pix_to_date;
        % check the number of non-zero values and accumulate over all pages
        % (write at end of pages loop)
        numpossig = numel(possigval);
        total_nonzero_signals = total_nonzero_signals + numpossig;
        nonzero_page_sizes(i) = numpossig;
        num_pix_to_date = num_pix_to_date + full_page_size;
        % write the existing pix data as if not compressed
        try
            fwrite(obj.file_id_, single(pix_data), 'float32');
            obj.check_write_error(obj.file_id_);
        catch ME
            exc = MException('HORACE:put_pix:io_error',...
                sprintf('Error writing input pixels for page N%d out of %d',i,n_pages));
            throw(exc.addCause(ME))
        end
        % note the end of the current page
        curpos = ftell(obj.file_id_); % current position
        % move to end of whole pixel data check position
        fseek(obj.file_id_,endpix2pos,'bof');
        pix_end_ta = ftell(obj.file_id_);
        %%{
        % recheck the non-zero size and ensure consistent
         pix2size = numel(possig);
        if pix2size ~= numpossig
            disp('sizes inconsistent');
        end
        % single array to store non-zero indices and values
        pix_data_2 = zeros(3,pix2size);
        pix_data_2(1,:) = possig;
        pix_data_2(2,:) = possigval;
        pix_data_2(3,:) = posvarval;
        pix_data_3(:,total_nonzero_signals+1-numpossig:total_nonzero_signals) ...
            =pix_data_2;
        % write it after all the pixels (all pages)
        try
            fwrite(obj.file_id_, single(pix_data_2), 'float32');
            obj.check_write_error(obj.file_id_);
        catch ME
            exc = MException('HORACE:put_pix:io_error',...
                sprintf('Error writing input pixels for page N%d out of %d',i,n_pages));
            throw(exc.addCause(ME))
        end
        % check the position at the end of the current pages of non-zero
        % signals and find how far it is from the original pix
        endpix2pos = ftell(obj.file_id_);
        % go back to where the main pix write got to last
        % and check it's where it is supposed to be
        if i~=n_pages
            fseek(obj.file_id_, curpos, 'bof');
            backpos = ftell(obj.file_id_);
            if backpos ~= curpos 
                disp('nav error');
            end
        end
    end % for loop i over pages
    % write 666 to mark the end of all the pixel data
    fwrite(obj.file_id_, numel(nonzero_page_sizes), 'single'); 
    fwrite(obj.file_id_, nonzero_page_sizes, 'single');
    fwrite(obj.file_id_, single(666),'single');
    endpix2pos = ftell(obj.file_id_);
    % we are at endpix2pos
    % return to start of pages and rewrite the number of non-zero signals
    fseek(obj.file_id_, pix_start_A, 'bof');
    try
        fwrite(obj.file_id_, single(total_nonzero_signals), 'float32');
        obj.check_write_error(obj.file_id_);
    catch ME
        exc = MException('HORACE:put_pix:io_error',...
            sprintf('Error writing initial non-zero-signal number'));
        throw(exc.addCause(ME))
    end
    obj.n_nonzeropixels = total_nonzero_signals;
    input_obj.n_nonzeropixels = total_nonzero_signals;
    pix_start_3 = ftell(obj.file_id_);
    % move to end of file again
    fseek(obj.file_id_, endpix2pos, 'bof' );
    endpix2apos = ftell(obj.file_id_);
else % input_obj is an array of pixel data, not a PixelData object. 
     % As it is in memory, write it as a single block
    fwrite(obj.file_id_, single(input_obj), 'float32');
    obj.check_write_error(obj.file_id_);
end
    fmt = cell(7,3);
    fmt{1,1} = 'single'; fmt{1,2} = 1;         fmt{1,3} = 'n_nonzero';
    fmt{2,1} = 'single'; fmt{2,2} = [9 double(obj.npixels)];fmt{2,3} = 'data';
    fmt{3,1} = 'single'; fmt{3,2} = 1;         fmt{3,3} = 'separator';
    fmt{4,1} = 'single'; fmt{4,2} = [3 total_nonzero_signals]; fmt{4,3} = 'data2';
    fmt{5,1} = 'single'; fmt{5,2} = 1;         fmt{5,3} = 'nnpixpages';
    fmt{6,1} = 'single'; fmt{6,2} = numel(nonzero_page_sizes);       fmt{6,3} = 'nnzpix';
    fmt{7,1} = 'single'; fmt{7,2} = 1;         fmt{7,3} = 'endflag2';
    mmf = memmapfile(obj.full_filename, ...
        'Format', fmt, ... %obj.get_memmap_format(tail), ...
        'Repeat', 1, ...
        'Writable', true, ...
        'Offset', pix_start_A);
end
