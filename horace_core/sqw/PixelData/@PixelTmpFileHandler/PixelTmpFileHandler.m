classdef PixelTmpFileHandler

    properties (Constant, Access=private)
        TMP_DIR_BASE_NAME_ = 'sqw_pix%09d.tmp_sqw';
        FILE_DATA_FORMAT_ = 'float32';
        SIZE_OF_FLOAT = 4;
    end

    properties(Dependent)
        page_size
    end

    properties(Access=private, SetAccess=immutable)
        file_path_ = '';  % The path to the directory in which to write the tmp files
        pix_id_ = -1;     % The ID of the PixelData instance linked to this object
        offset_ = 0;      % Offset of the filehandler's pix in file (for parallel usage)
    end

    properties (Access=private)
        has_tmp_file_ = false;  % Logical array mapping page to whether that page has a tmp file
        page_size_ = get(hpc_config, 'mem_chunk_size');
    end

    methods

        function obj = PixelTmpFileHandler(pix_id, has_tmp_files, offset, page_size)
        % Construct a PixelTmpFileHandler object
        %
        % Input
        % -----
        % pix_id   The ID of the PixelData instance this object is linked to.
        %          This sets the tmp directory name
        % has_tmp_files  Logical array saying if tmp exist for the given page
            obj.pix_id_ = pix_id;
            obj.file_path_ = obj.generate_tmp_pix_file_path_();
            if exist('has_tmp_files', 'var')
                obj.has_tmp_file_ = has_tmp_files;
            end
            if exist('offset', 'var')
                obj.offset_ = offset;
            end
            if exist('page_size', 'var')
                obj.page_size = page_size;
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
            if ~exist('ncols', 'var')
                ncols = 1;
            end

            [file_id, clean_up] = obj.open_file_('rb');

            do_fseek(file_id, obj.page_size*page_number, 'cof');

            page_shape = [ncols, Inf];
            raw_pix = do_fread(file_id, page_shape, obj.FILE_DATA_FORMAT_);
        end

        function raw_pix = load_pixels_at_indices(obj, indices, ncols)
            if nargin == 2
                ncols = 1;
            end

            PIXEL_SIZE = obj.SIZE_OF_FLOAT*ncols;  % bytes

            [file_id, clean_up] = obj.open_file_('rb');
            [read_sizes, seek_sizes, idx_map] = obj.get_pix_locs(indices);
            raw_pix = zeros(ncols, numel(indices));

            out_pix_start = 1;
            for block_num = 1:numel(read_sizes)
                do_fseek(file_id, seek_sizes(block_num)*PIXEL_SIZE, 'cof');

                out_pix_end = out_pix_start + read_sizes(block_num) - 1;
                read_size = [ncols, read_sizes(block_num)];
                raw_pix(:, out_pix_start:out_pix_end) = ...
                    do_fread(file_id, read_size, obj.FILE_DATA_FORMAT_);

                out_pix_start = out_pix_start + read_sizes(block_num);
            end

            if ~isempty(idx_map)
                raw_pix = raw_pix(:, idx_map);
            end
        end

        function obj = write_pixels(obj, page_number, raw_pix)
        % Write the given pixel data to tmp file with the given page number
        %
        % Inputs
        % ------
        % page_number   The number of the page being written, this sets the tmp file name
        % raw_pix       The raw pixel data array to write
        %

            [file_id, clean_up] = obj.open_file_('wb');

            do_fseek(file_id, obj.page_size*page_number, 'cof');

            try
                fwrite(file_id, raw_pix, obj.FILE_DATA_FORMAT_);
            catch ME
                switch ME.identifier
                  case 'MATLAB:badfid_mx'
                    error('PIXELTMPFILEHANDLER:write_float_data_', ...
                          ['Could not write to file with ID ''%d'':\n' ...
                           'The file is not open'], file_id);
                  otherwise
                    tmp_file_path = fopen(file_id);
                    error('PIXELTMPFILEHANDLER:write_float_data_', ...
                          'Could not write to file ''%s'':\n%s', ...
                          tmp_file_path, ferror(file_id));
                end
            end

            obj.has_tmp_file_ = true;
        end

        function new_path = copy_file(obj, target_pix_id)
        % Copy the temporary files managed by this class instance to a new folder
        %
        % Input
        % -----
        % target_pix_id   The ID of the PixelData instance the new tmp folder
        %                 will be linked to
        %
        % Output
        % ------
        % new_path        New location of moved file
        %
            new_path = obj.generate_tmp_dir_path_(target_pix_id);
            [status, err_msg] = copyfile(obj.file_path_, new_path);
            if status == 0
                error('PIXELDATA:copy_file', ...
                      'Could not copy PixelData tmp files from ''%s'' to ''%s'':\n%s', ...
                      obj.file_path_, new_path, err_msg);
            end
        end

        function obj = move_file(obj, target_file, is_perm)
        % Move the temporary file generally to become permanent sqw when done
        %
        % Input
        % -----
        % target_file  new location to move file to
        %
        % is_perm      whether to treat the move as a relocation, default: true
        %

            if ~exist('is_perm', 'var')
                is_perm = true;
            end

            % if we have a temp file, move it
            if obj.has_tmp_file_
                movefile(obj.file_path_, target_file);
                % If it's permanent, we don't have a temp file anymore
                obj.has_tmp_file_ = ~is_perm;
            end

            % if it's not permenent, we now point to our new temp file
            if ~is_perm
                obj.file_path_ = target_file;
            end
        end

        function obj = delete_files(obj)
        % Delete the tmp files
            if obj.has_tmp_file_
                delete(obj.file_path_);
            end
            obj.has_tmp_file_ = false;
        end

        function has = has_tmp_file(obj)
        % Return true if a tmp file exists
            has = obj.has_tmp_file_;
        end

        function obj = set.page_size(obj, val)
            if val < SIZE_OF_FLOAT
                error('PIXELTMPFILEHANDLER:invalid_argument', 'Page cannot be smaller than 1 float')
            end
            obj.page_size_ = val;
        end

        function page_size = get.page_size(obj)
            page_size = obj.page_size_;
        end

    end

    methods (Access=private)
        function [file_id, clean_up] = open_file_(obj, rw)
            file_id = fopen(obj.file_path_, rw);
            if file_id < 0
                error('PIXELTMPFILEHANDLER:write_page', ...
                      'Could not open file ''%s'' for writing.\n', obj.file_path_);
            end
            clean_up = onCleanup(@() fclose(file_id));

            do_fseek(file_id, offset, 'bof');

        end


        function file_path = generate_tmp_pix_file_path_(obj)
        % Generate the file path to a tmp file with the given page number
            file_name = sprintf(obj.TMP_FILE_BASE_NAME_, pix_id);
            file_path = fullfile(pc.working_directory, file_name);
        end


    end

    methods(Static)
        function [read_sizes, seek_sizes, idx_map] = get_pix_locs(indices)
            indices_monotonic = issorted(indices, 'strictascend');
            if ~indices_monotonic
                [indices, ~, idx_map] = unique(indices);
            else
                idx_map = [];
            end

            [read_sizes, seek_sizes] = get_read_and_seek_sizes(indices);

        end
    end

end
