classdef PixelTmpFileHandler

    properties (Constant, Access=private)
        TMP_FILE_BASE_NAME_ = 'sqw_pix%09d.tmp_sqw';
        FILE_DATA_FORMAT_ = 'single';
        SIZE_OF_FLOAT = 4;
        NUM_COLS = 9;
    end

    properties(Dependent)
        page_size;
        file_path;
        pix_per_page;
        num_pixels;
    end

    properties(GetAccess=public, SetAccess=immutable, Hidden)
        file_path_ = '';  % The path to the directory in which to write the tmp file
        pix_id_ = -1;     % The ID of the PixelData instance linked to this object
        offset_ = 0;      % Offset of the filehandler's pix in file (for parallel usage)
    end

    properties
        has_tmp_file_ = false;  % whether object has a tmp file
    end

    properties (Access=private)
        page_size_ = get(hor_config, 'mem_chunk_size');
        file_id_ = -1;
    end

    methods

        function obj = PixelTmpFileHandler(pix_id, has_tmp_file, offset, page_size)
        % Construct a PixelTmpFileHandler object
        %
        % Input
        % -----
        % pix_id   The ID of the PixelData instance this object is linked to.
        %          This sets the tmp directory name
        % has_tmp_file  Logical array saying if tmp exist for the given page
            obj.pix_id_ = pix_id;
            obj.file_path_ = obj.generate_tmp_pix_file_path_();
            if exist('has_tmp_file', 'var')
                obj.has_tmp_file_ = has_tmp_file;
            end
            if exist('offset', 'var')
                obj.offset_ = offset;
            end
            if exist('page_size', 'var')
                obj.page_size = page_size;
            end
        end

        function new_obj = copy(obj, obj_id)
            new_obj = PixelTmpFileHandler(obj_id, false, obj.offset_, obj.page_size);
            new_obj.has_tmp_file_ = obj.copy_file(obj_id);
            if new_obj.has_tmp_file_
                new_obj = new_obj.open_file_();
            end
        end

        function raw_pix = load_pix(obj, pix_start, pix_end)
        % Load a page of data from the tmp file with the given page number
        %
        % Input
        % -----
        % page_number   The number of the page to read data from
        % ncols         The number of columns in the page, used for reshaping
        %               (default = 1)
        %
            start_idx = sub2ind([obj.NUM_COLS, obj.num_pixels], 1, pix_start);
            end_idx = start_idx - 1 + (pix_end-pix_start+1)*obj.NUM_COLS;

            raw_pix = reshape(double(obj.file_id_.Data(start_idx:end_idx)), [obj.NUM_COLS, pix_end - pix_start + 1]);
        end

        function raw_pix = load_pixels_at_indices(obj, indices)
            raw_pix = obj.load_cols_at_indices(indices, 1:obj.NUM_COLS);
        end

        function raw_pix = load_cols_at_indices(obj, pix_indices, col_indices)

            raw_pix = zeros(numel(col_indices), numel(pix_indices));
            pix_indices = (pix_indices - 1)*obj.NUM_COLS;

            for i = 1:numel(col_indices)
                raw_pix(i, :) = obj.file_id_.Data(pix_indices+col_indices(i));
            end
            raw_pix = double(raw_pix);
        end

        function obj = set_all_indices(obj, col_indices, data)
            if ~isscalar(data)
                for i = 1:numel(col_indices)
                    obj.file_id_.Data(col_indices(i):obj.NUM_COLS:obj.num_pixels*obj.NUM_COLS) = data(i, :);
                end
            else
                for i = 1:numel(col_indices)
                    obj.file_id_.Data(col_indices(i):obj.NUM_COLS:obj.num_pixels*obj.NUM_COLS) = data;
                end
            end
        end

        function obj = set_pix_indices(obj, pix_indices, col_indices, data)
            pix_indices = (pix_indices - 1)*obj.NUM_COLS;

            for i = 1:numel(col_indices)
                obj.file_id_.Data(pix_indices+col_indices(i)) = data(i, :);
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

            start_idx = (page_number-1)*obj.pix_per_page+1;
            raw_pix = single(raw_pix);
            ind = sub2ind([obj.NUM_COLS obj.num_pixels], 1, start_idx);
            obj.file_id_.Data(ind:ind+numel(raw_pix)-1) = raw_pix;
        end

        function tmp_file = copy_file(obj, target_pix_id)
        % Copy the temporary file managed by this class instance to a new folder
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
            tmp_file = obj.has_tmp_file_;
            if tmp_file
                new_path = obj.generate_tmp_pix_file_path_(target_pix_id);
                [status, err_msg] = copyfile(obj.file_path_, new_path);
                if status == 0
                    error('PIXELDATA:copy_file', ...
                          'Could not copy PixelData tmp file from ''%s'' to ''%s'':\n%s', ...
                          obj.file_path_, new_path, err_msg);
                end
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
                fclose(obj.file_id_);
                obj = obj.open_file_();
            end
        end

        function obj = delete_file(obj)
        % Delete the tmp file
            if obj.has_tmp_file_
                delete(obj.file_path_);
            end
            obj.has_tmp_file_ = false;
        end

        function has = has_tmp_file(obj)
        % Return true if a tmp file exists
            has = obj.has_tmp_file_;
        end

        function page_size = get.page_size(obj)
            page_size = obj.page_size_;
        end

        function pix_per_page = get.pix_per_page(obj)
            pix_per_page = obj.page_size;
        end

        function obj = set.page_size(obj, val)
            if val < 1
                error('PIXELTMPFILEHANDLER:invalid_argument', 'Page cannot be smaller than 1 float')
            end
            obj.page_size_ = val;
        end

        function npix = get.num_pixels(obj)
            npix = numel(obj.file_id_.Data) / obj.NUM_COLS;
        end

        function fp = get.file_path(obj)
            fp = obj.file_path_;
        end

    end

    methods (Hidden)
        function obj = append_pixels(obj, pixels)

            fid = fopen(obj.file_path_,'a');
            fwrite(fid, pixels, obj.FILE_DATA_FORMAT_);
            fclose(fid);
            obj = obj.open_file_();
        end

        function obj = open_file_(obj)
            if ~is_file(obj.file_path_)
                fid = fopen(obj.file_path_, 'w');
                fclose(fid);
            end

            obj.file_id_ = memmapfile(obj.file_path_, ...
                                      'Format', obj.FILE_DATA_FORMAT_, ...
                                      'Writable', true ...
                                     );
            obj.has_tmp_file_ = true;
        end

    end

    methods (Access=private)

        function file_path = generate_tmp_pix_file_path_(obj, pix_id)
        % Generate the file path to a tmp file with the given page number
            if ~exist('pix_id', 'var')
                pix_id = obj.pix_id_;
            end

            pc = parallel_config;

            file_name = sprintf(obj.TMP_FILE_BASE_NAME_, pix_id);
            file_path = fullfile(pc.working_directory, file_name);
        end

        function offset = get_start_of_page_(obj, page_number)
            offset = max(obj.page_size*(page_number-1)/obj.NUM_COLS/obj.SIZE_OF_FLOAT, 0)+1;
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

    % Unused methods for turning back into file-based if necessary in future
    % methods(Deprecated)
    %     function seek_(obj, offset, mode)
    %         do_fseek(obj.file_id_, obj.offset_+offset, mode);
    %     end

    %     function write_(obj, data)
    %         fwrite(obj.file_id_, data, obj.FILE_DATA_FORMAT_);
    %     end

    %     function data = read_(obj, shape, skip)
    %         if ~exist('skip', 'var')
    %             skip = 0;
    %         end
    %         data = fread(obj.file_id_, shape, obj.FILE_DATA_FORMAT_, skip);
    %         data = double(data);
    %     end
    % end

end
