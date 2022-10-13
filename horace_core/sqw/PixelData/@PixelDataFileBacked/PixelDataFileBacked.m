classdef PixelDataFileBacked < PixelDataBase

    properties (Access=private)
        f_accessor_;  % instance of faccess object to access pixel data from file
        tmp_io_handler_;  % a PixelTmpFileHandler object that handles reading/writing of tmp files
        page_number_ = 1;  % the index of the currently loaded page
        file_path_ = '';  % the path to the file backing this object
    end

    properties (Constant)
        is_filebacked = true;
    end

    properties(Access=public,Hidden)
        % Contains the range(min/max value) of a block of pixels,
        % changed by set.pixels methods. Exposed to be used in algorithms,
        % looping over the paged pixels and changing object using
        % coordinate setters to calculate and set-up correct global pixels
        % range in conjunction with set_range method at the end of the loop.
        page_range;
    end

    properties (Dependent)
        file_path;  % The file that the pixel data has been read from, empty if no file
        page_size;  % The number of pixels in the current page
        base_page_size;  % The number of pixels that can fit in one page of data
        n_pages;
    end

    properties(Dependent, Access=protected)
        % points to raw_data_ but with a layer of validation for setting correct array sizes
        data_;
        % the pixel index in the file of the first pixel in the cache
        pix_position_;
    end

    methods
        function obj = PixelDataFileBacked()
            % Construct a File-backed PixelData object from the given data. Default
            % construction initialises the underlying data as an empty (9 x 0)
            % array.
        end

        % --- Operator overrides ---
        function delete(obj)
        % Class destructor to delete any temporary files
            if ~isempty(obj.tmp_io_handler_)
                obj.tmp_io_handler_.delete_files();
            end
        end

        function saveobj(obj)
            error('HORACE:PixelData:runtime_error',...
                  'Can not save filebacked PixelData object');
        end

        function has_more = has_more(obj)
        % Returns true if there are subsequent pixels stored in the file that
        % are not held in the current page
        %
        %    >> has_more = pix.has_more();
        %
            has_more = obj.curr_position_  <= obj.num_pixels;
        end

        function [current_page_num, total_num_pages] = advance(obj, varargin)
        % Load the next page of pixel data from the file backing the object
        %
        % This function will throw a PIXELDATA:advance error if attempting to
        % advance past the final page of data in the file.
        %
        % This function does nothing if the pixel data is not file-backed.
        %
        %  >> obj.advance()
        %  >> obj.advance('nosave', true)
        %
        % Inputs:
        % -------
        % nosave  Keyword argument. Set to true to discard changes to cache.
        %         (default: false)
        %
        % Outputs:
        % --------
        % current_page_number  The new page and total number of pages advance will
        % walk through to complete the algorithm
        %

            try
                [current_page_num,total_num_pages]=obj.move_to_page(obj.page_number_ + 1, varargin{:});
            catch ME
                switch ME.identifier
                  case 'HORACE:PixelData:runtime_error'
                    error('HORACE:PixelData:runtime_error', ...
                          'Attempting to advance past final page of data in %s', ...
                          obj.file_path);
                  otherwise
                    rethrow(ME);
                end
            end
        end

        function set.file_path(obj,val)
            move_file
        end

    end

    methods (Access = private)
        function obj = init_from_file_accessor_(obj, f_accessor)
        % Initialise a PixelData object from a file accessor
            obj.f_accessor_ = f_accessor;
            obj.file_path_ = fullfile(obj.f_accessor_.filepath, ...
                                      obj.f_accessor_.filename);
            obj.page_number_ = 1;
            obj.num_pixels_ = double(obj.f_accessor_.npixels);

            obj.data();
            obj.pix_range_ = f_accessor.get_pix_range();
            obj.tmp_io_handler_ = PixelTmpFileHandler(obj.object_id_);

        end

        function obj = load_current_page_if_data_empty_(obj)
            % Check if there's any data in the current page and load a page if not
            %   This function does nothing if pixels are not file-backed.
            if obj.cache_is_empty_() && obj.is_filebacked()
                obj = obj.load_page_(obj.page_number_);
            end
        end

        function obj = load_page_(obj, page_number)
            % Load the data for the given page index
            if obj.page_is_dirty_(page_number) && obj.tmp_io_handler_.page_has_tmp_file(page_number)
                % load page from tmp file
                obj.load_dirty_page_(page_number);
            else
                % load page from sqw file
                obj.load_clean_page_(page_number);
                obj.set_page_dirty_(false, page_number);
            end
            obj.page_number_ = page_number;
            obj.dirty_page_edited_ = false;
        end

        function obj = load_clean_page_(obj, page_number)
            % Load the given page of data from the sqw file backing this object
            pix_idx_start = (page_number - 1)*obj.base_page_size + 1;
            if pix_idx_start > obj.num_pixels
                error('HORACE:PixelData:runtime_error', ...
                    'pix_idx_start exceeds number of pixels in file. %i >= %i', ...
                    pix_idx_start, obj.num_pixels);
            end
            % Get the index of the final pixel to read given the maximum page size
            pix_idx_end = min(pix_idx_start + obj.base_page_size - 1, obj.num_pixels);

            obj.data_ = obj.f_accessor_.get_raw_pix(pix_idx_start, pix_idx_end);
            if obj.page_size == obj.num_pixels
                % Delete accessor and close the file if all pixels have been read
                obj.f_accessor_ = [];
            end
        end

        function obj = load_dirty_page_(obj, page_number)
            % Load a page of data from a tmp file
            obj.data_ = obj.tmp_io_handler_.load_page(page_number, ...
                obj.PIXEL_BLOCK_COLS_);
        end

        function obj = write_dirty_page_(obj)
            % Write the current page's pixels to a tmp file
            if isempty(obj.tmp_io_handler_)
                obj.tmp_io_handler_ = PixelTmpFileHandler(obj.object_id_);
            end
            obj.tmp_io_handler_ = obj.tmp_io_handler_.write_page(obj.page_number_, obj.data);
        end

        function is = page_is_dirty_(obj, page_number)
            % Return true if the given page is dirty
            is = ~(page_number > numel(obj.page_dirty_));
            is = is && obj.page_dirty_(page_number);
        end

        function obj = set_page_dirty_(obj, is_dirty, page_number)
            % Mark the given page as "dirty" i.e. the data in the cache does not
            % match the data in the original SQW file
            %
            % Input
            % -----
            % is_dirty     Logical specifying if the page is dirty
            % page_number  The page number to mark as dirty (default is current page)
            %
            if nargin == 2
                page_number = obj.page_number_;
            end
            obj.page_dirty_(page_number) = is_dirty;
            obj.dirty_page_edited_ = is_dirty;
        end

        function page_size = calculate_page_size_(obj, mem_alloc)
            % Calculate number of pixels that fit in the given memory allocation
            num_bytes_in_pixel = sqw_binfile_common.FILE_PIX_SIZE;
            page_size = floor(mem_alloc/num_bytes_in_pixel);
            page_size = max(page_size, size(obj.raw_data_, 2));
        end

        function is = cache_is_empty_(obj)
            % Return true if no pixels are currently held in memory
            is = isempty(obj.data_);
        end

        function num_pages = get_num_pages_(obj)
            num_pages = max(ceil(obj.num_pixels/obj.base_page_size), 1);
        end

        function reset_changed_coord_range(obj,field_name)
            % Recalculate and set appropriate range of pixel coordinates.
            % The coordinates are defined by the selected field
            %
            % Sets up the property page_range defining the range of block
            % of pixels chaned at current iteration.
            %
            obj = obj.load_current_page_if_data_empty_();
            if isempty(obj.raw_data_)
                obj.pix_range_   = PixelDataBase.EMPTY_RANGE_;
                obj.page_range = PixelDataBase.EMPTY_RANGE_;
                return
            end
            ind = obj.FIELD_INDEX_MAP_(field_name);

            loc_range = [min(obj.raw_data_(ind,:),[],2),max(obj.raw_data_(ind,:),[],2)]';
            obj.page_range(:,ind) = loc_range;

            range = [min(obj.pix_range_(1,ind),loc_range(1,:));...
                     max(obj.pix_range_(2,ind),loc_range(2,:))];
            obj.pix_range_(:,ind) = range;
        end
    end

    end

end