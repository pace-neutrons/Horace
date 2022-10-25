classdef PixelDataFileBacked < PixelDataBase

    properties (Access=private)
        f_accessor_;  % instance of faccess object to access pixel data from file
        tmp_io_handler_;  % a PixelTmpFileHandler object that handles reading/writing of tmp files
        page_number_ = 1;  % the index of the currently loaded page
        file_path_ = '';  % the path to the file backing this object
        page_dirty_ = false;  % array mapping from page_number to whether that page is dirty
        dirty_page_edited_ = false;  % array mapping from page_number to whether that page is dirty
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
        page_memory_size_ = get(hor_config, 'mem_chunk_size');  % the maximum amount of memory a page can use
    end

    properties (Dependent)
        file_path;  % The file that the pixel data has been read from, empty if no file
        n_pages;
    end

    properties(Dependent, Access=protected)
        % the pixel index in the file of the first pixel in the cache
        pix_position_;
    end

    methods
        function obj = PixelDataFileBacked(init, mem_alloc, upgrade)
            % Construct a File-backed PixelData object from the given data. Default
            % construction initialises the underlying data as an empty (9 x 0)
            % array.

            if ~exist('upgrade', 'var')
                upgrade = true;
            end

            obj.object_id_ = randi([10, 99999], 1, 1);
            obj.tmp_io_handler_ = PixelTmpFileHandler(obj.object_id_);

            if exist('init', 'var')
                if isstruct(init)
                    obj = obj.loadobj(init);
                elseif isa(init, 'PixelDataFileBacked')
                    obj = obj.init_from_file_accessor_(init.f_accessor_);

                elseif ischar(init) || isstring(init)
                    if ~is_file(init)
                        error('HORACE:PixelDataFileBacked:invalid_argument', ...
                              'Cannot find file to load (%s)', init)
                    end

                    init = sqw_formats_factory.instance().get_loader(init);
                    obj = obj.init_from_file_accessor_(init);

                elseif isa(init, 'sqw_file_interface')
                    obj = obj.init_from_file_accessor_(init);

                else
                    error('HORACE:PixelDataFileBacked:invalid_argument', ...
                          'Cannot construct PixelDataFileBacked from class (%s)', class(init))
                end
            end

            if any(obj.pix_range == obj.EMPTY_RANGE_, 'all') && upgrade
                if get(herbert_config, 'log_level') > 0
                    fprintf('*** Recalculating actual pixel range missing in file %s:\n', ...
                            init.filename);
                end
                obj.recalc_pix_range();
            end

            if exist('mem_alloc', 'var') && ~isempty(mem_alloc)
                obj.page_memory_size_ = mem_alloc;
            end
        end

        function data = get_raw_data(obj)
            data = obj.raw_data_;
        end

        function set_raw_data(obj, pixel_data)
            % This setter provides rules for internally setting cached data
            %  This is the only method that should ever touch obj.raw_data_

            % The need for multiple layers of getters/setters for the raw data
            % should be removed when the public facing getters/setters are removed.
            if size(pixel_data, 1) ~= obj.PIXEL_BLOCK_COLS_
                msg = ['Cannot set pixel data, invalid dimensions. Axis 1 must '...
                    'have length %i, found ''%i''.'];
                error('HORACE:PixelData:invalid_argument', msg, obj.PIXEL_BLOCK_COLS_, ...
                    size(pixel_data, 1));
            elseif ~isnumeric(pixel_data)
                msg = ['Cannot set pixel data, invalid type. Data must have a '...
                    'numeric type, found ''%s''.'];
                error('HORACE:PixelData:invalid_argument', msg, class(pixel_data));
            end
            obj.raw_data_ = pixel_data;
        end

        function prp = get_prop(obj, fld)
            obj = obj.load_current_page_if_data_empty_();
            prp = obj.data_(obj.FIELD_INDEX_MAP_(fld), :);
        end

        function set_prop(obj, fld, val)
            obj = obj.load_current_page_if_data_empty_();
            obj.data_(obj.FIELD_INDEX_MAP_(fld), :) = val;
            if ismember(fld, ["u1", "u2", "u3", "dE", "q_coordinates", "coordinates", "all"])
                obj.reset_changed_coord_range(fld);
            end
            obj.set_page_dirty_(true);
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
            has_more = obj.pix_position_ + obj.base_page_size  <= obj.num_pixels;
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

        function path = get.file_path(obj)
            path = obj.file_path_;
        end

        function set.file_path(obj,val)
            obj.tmp_io_handler_.move_file(val);
            obj.file_path_ = val;
        end

        function pix_position = get.pix_position_(obj)
            pix_position = (obj.page_number_ - 1)*obj.base_page_size + 1;
        end

        function np = get.n_pages(obj)
            np = max(ceil(obj.num_pixels_*sqw_binfile_common.FILE_PIX_SIZE/obj.page_memory_size_),1);
        end

    end

    methods (Access = private)

        function obj = load_current_page_if_data_empty_(obj)
            % Check if there's any data in the current page and load a page if not
            %   This function does nothing if pixels are not file-backed.
            if obj.cache_is_empty_() && obj.is_filebacked
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

        function num_pages = get_num_pages_(obj)
            num_pages = max(ceil(obj.num_pixels/obj.base_page_size), 1);
        end

    end

    methods (Access = ?PixelDataBase)
        function is = cache_is_empty_(obj)
            % Return true if no pixels are currently held in memory
            is = isempty(obj.data_);
        end

        function obj = init_from_file_accessor_(obj, f_accessor)
        % Initialise a PixelData object from a file accessor
            obj.f_accessor_ = f_accessor;
            obj.file_path_ = fullfile(obj.f_accessor_.filepath, ...
                                      obj.f_accessor_.filename);
            obj.page_number_ = 1;
            obj.num_pixels_ = double(obj.f_accessor_.npixels);

            obj.data();
            obj.pix_range_ = obj.f_accessor_.get_pix_range();

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

            if field_name == "all"
                field_name = "coordinates"
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
