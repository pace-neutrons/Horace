classdef PixelTmpFileHandler

properties (Constant, Access=private)
    TMP_DIR_BASE_NAME_ = 'sqw_pix%05d';
    TMP_FILE_BASE_NAME_ = '%09d.tmp';
    FILE_DATA_FORMAT_ = 'float32';
end

properties (Access=private)
    tmp_dir_path_ = '';  % The path to the directory in which to write the tmp files
    pix_id_ = -1;        % The ID of the PixelData instance linked to this object
    has_tmp_file_ = false;  % Logical array mapping page to whether that page has a tmp file
end

methods

    function obj = PixelTmpFileHandler(pix_id, has_tmp_files)
        % Construct a PixelTmpFileHandler object
        %
        % Input
        % -----
        % pix_id   The ID of the PixelData instance this object is linked to.
        %          This sets the tmp directory name
        % has_tmp_files  Logical array saying if tmp exist for the given page
        obj.pix_id_ = pix_id;
        obj.tmp_dir_path_ = obj.generate_tmp_dir_path_(obj.pix_id_);
        if exist('has_tmp_files', 'var')
            obj.has_tmp_file_ = has_tmp_files;
        end
    end

    function raw_pix = load_page(obj, page_number, ncols)
        % Load a page of data from the tmp file with the given page number
        %
        % Input
        % -----
        % page_number   The number of the page to read data from
        % ncols         The number of columns in the page, used for reshaping
        %               (default = 1)
        %
        if nargin == 2
            ncols = 1;
        end

        tmp_file_path = obj.generate_tmp_pix_file_path_(page_number);
        [file_id, err_msg] = fopen(tmp_file_path, 'rb');
        if file_id < 0
            error('PIXELTMPFILEHANDLER:load_page', ...
                  'Could not open ''%s'' for reading:\n%s', tmp_file_path, ...
                  err_msg);
        end
        clean_up = onCleanup(@() fclose(file_id));

        page_shape = [ncols, Inf];
        raw_pix = do_fread(file_id, page_shape, obj.FILE_DATA_FORMAT_);
    end

    function raw_pix = load_pixels_at_indices(obj, page_number, indices, ncols)
        if nargin == 2
            ncols = 1;
        end

        NUM_BYTES_IN_FLOAT = 4;
        PIXEL_SIZE = NUM_BYTES_IN_FLOAT*ncols;  % bytes

        tmp_file_path = obj.generate_tmp_pix_file_path_(page_number);
        [file_id, err_msg] = fopen(tmp_file_path, 'rb');
        if file_id < 0
            error('PIXELTMPFILEHANDLER:load_page', ...
                  'Could not open ''%s'' for reading:\n%s', tmp_file_path, ...
                  err_msg);
        end
        clean_up = onCleanup(@() fclose(file_id));

        indices_monotonic = issorted(indices, 'strictascend');
        if ~indices_monotonic
            [indices, ~, idx_map] = unique(indices);
        end

        [read_sizes, seek_sizes] = get_read_and_seek_sizes(indices);

        raw_pix = zeros(ncols, numel(indices));

        num_pix_read = 0;
        for block_num = 1:numel(read_sizes)
            do_fseek(file_id, seek_sizes(block_num)*PIXEL_SIZE, 'cof');

            out_pix_start = num_pix_read + 1;
            out_pix_end = out_pix_start + read_sizes(block_num) - 1;
            read_size = [ncols, read_sizes(block_num)];
            read_pix = do_fread(file_id, read_size, obj.FILE_DATA_FORMAT_);
            raw_pix(:, out_pix_start:out_pix_end) = read_pix;

            num_pix_read = num_pix_read + read_sizes(block_num);
        end
        if ~indices_monotonic
            raw_pix = raw_pix(:, idx_map);
        end
    end

    function obj = write_page(obj, page_number, raw_pix)
        % Write the given pixel data to tmp file with the given page number
        %
        % Inputs
        % ------
        % page_number   The number of the page being written, this sets the tmp file name
        % raw_pix       The raw pixel data array to write
        %
        tmp_file_path = obj.generate_tmp_pix_file_path_(page_number);
        if ~exist(obj.tmp_dir_path_, 'dir')
            mkdir(obj.tmp_dir_path_);
        end

        file_id = fopen(tmp_file_path, 'wb');
        if file_id < 0
            error('PIXELTMPFIELHANDLER:write_page', ...
                  'Could not open file ''%s'' for writing.\n', tmp_file_path);
        end
        clean_up = onCleanup(@() fclose(file_id));

        obj.write_float_data_(file_id, raw_pix);
        obj.has_tmp_file_(page_number) = true;
    end

    function has_tmp_file = copy_folder(obj, target_pix_id)
        % Copy the temporary files managed by this class instance to a new folder
        %
        % Input
        % -----
        % target_pix_id   The ID of the PixelData instance the new tmp folder
        %                 will be linked to
        %
        % Output
        % ------
        % has_tmp_file    Logical array of which pages have tmp files
        %
        has_tmp_file = false;
        if ~is_folder(obj.tmp_dir_path_)
            return;
        end

        new_dir_path = obj.generate_tmp_dir_path_(target_pix_id);
        [status, err_msg] = copyfile(obj.tmp_dir_path_, new_dir_path);
        if status == 0
            error('PIXELDATA:copy_folder', ...
                  'Could not copy PixelData tmp files from ''%s'' to ''%s'':\n%s', ...
                  obj.tmp_dir_path_, new_dir_path, err_msg);
        end
        has_tmp_file = obj.has_tmp_file_;
    end

    function obj = delete_files(obj)
        % Delete the directory containing the tmp files
        if exist(obj.tmp_dir_path_, 'dir')
            rmdir(obj.tmp_dir_path_, 's');
        end
        obj.has_tmp_file_ = false;
    end

    function has = page_has_tmp_file(obj, page_number)
        % Return true if the given page was written to a tmp file
        if page_number > numel(obj.has_tmp_file_)
            has = false;
        else
            has = obj.has_tmp_file_(page_number);
        end
    end

end

methods (Access=private)

    function obj = write_float_data_(obj, file_id, pix_data)
        % Write the given data to the file corresponding to the given file ID
        % in float32
        SIZE_OF_FLOAT = 4;
        chunk_size = hor_config().mem_chunk_size/SIZE_OF_FLOAT;

        try
            for start_idx = 1:chunk_size:numel(pix_data)
                end_idx = min(start_idx + chunk_size - 1, numel(pix_data));
                fwrite(file_id, pix_data(start_idx:end_idx), obj.FILE_DATA_FORMAT_);
            end
        catch ME
            switch ME.identifier
            case 'MATLAB:badfid_mx'
                error('PIXELTMPFIELHANDLER:write_float_data_', ...
                      ['Could not write to file with ID ''%d'':\n' ...
                       'The file is not open'], file_id);
            otherwise
                tmp_file_path = fopen(file_id);
                error('PIXELTMPFIELHANDLER:write_float_data_', ...
                      'Could not write to file ''%s'':\n%s', ...
                      tmp_file_path, ferror(file_id));
            end
        end
    end

    function tmp_file_path = generate_tmp_pix_file_path_(obj, page_number)
        % Generate the file path to a tmp file with the given page number
        file_name = sprintf(obj.TMP_FILE_BASE_NAME_, page_number);
        tmp_file_path = fullfile(obj.tmp_dir_path_, file_name);
    end

    function tmp_dir_path = generate_tmp_dir_path_(obj, pix_id)
        % Generate the file path to the tmp directory for this object instance
        tmp_dir_name = sprintf(obj.TMP_DIR_BASE_NAME_, pix_id);
        pc = parallel_config;
        tmp_dir_path = fullfile(pc.working_directory, tmp_dir_name);
    end

end

end
