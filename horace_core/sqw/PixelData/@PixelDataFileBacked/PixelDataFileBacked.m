classdef PixelDataFileBacked < PixelDataBase
    % PixelDataFileBacked Provides an interface for access to file-backed pixel data
    %
    %   This class provides getters and setters for each data column in an SQW
    %   pixel array. You can access the data using the attributes listed below,
    %   using the get_data() method (to retrieve column data) or using the
    %   get_pixels() method (retrieve row data).
    %
    %   Construct this class with an 9 x N array, a file path to an SQW object or
    %   an instance of sqw_binfile_common.
    %
    %   >> pix_data = PixelDataFileBacked(data);
    %   >> pix_data = PixelDataFileBacked('/path/to/sqw.sqw');
    %   >> pix_data = PixelDataFileBacked(faccess_obj);
    %
    %   No pixel data will be loaded from the file on construction.
    %   Data will be loaded when a getter is called e.g. pix_data.signal. Data will
    %   be loaded in pages such that the data held in memory will not exceed `mem_chunk_size`
    %
    %   The file-backed operations work by loading "pages" of data into memory as
    %   required. If editing pixels, to avoid losing changes, if a page has been
    %   edited and the next page is then loaded, the "dirty" page will be written
    %   to a tmp file. This class's getters will then retrieve data from the tmp
    %   file if that data is requested from the "dirty" page. Note that "dirty"
    %   pages are written to tmp files as floats, but stored in memory as double.
    %   This means data is truncated when moving pages, hence pixel data should not
    %   be relied upon being accurate to double precision.
    %
    % Usage:
    %
    %   >> pix_data = PixelDataFileBacked(data)
    %   >> signal = pix_data.signal;
    %
    %  or equivalently:
    %
    %   >> pix_data = PixelDataFileBacked();
    %   >> pix_data.data = data;
    %   >> signal = pix_data.get_data('signal');
    %
    %  To retrieve multiple fields of data, e.g. run_idx and energy_idx, for pixels 1 to 10:
    %
    %   >> pix_data = PixelDataFileBacked(data);
    %   >> signal = pix_data.get_data({'run_idx', 'energy_idx'}, 1:10);
    %
    %  To retrieve data for pixels 1, 4 and 10 (returning another PixelData object):
    %
    %   >> pix_data = PixelDataFileBacked(data);
    %   >> pixel_subset = pix_data.get_pixels([1, 4, 10])
    %
    %  To sum the signal of a file-backed object where the page size is less than
    %  amount of data in the file:
    %
    %   >> pix = PixelDataFileBacked('my_data.sqw')
    %   >> signal_sum = 0;
    %   >> while pix.has_more()
    %   >>     signal_sum = signal_sum + pix.signal;
    %   >>     pix.advance();
    %   >> end
    %
    % Properties:
    %   u1, u2, u3     - The 1st, 2nd and 3rd dimensions of the Crystal
    %                    Cartesian coordinates in projection axes, units are per Angstrom (1 x n arrays)
    %   dE             - The energy transfer value for each pixel in meV (1 x n array)
    %   coordinates    - The coords in projection axes of the pixel data [u1, u2, u3, dE] (4 x n array)
    %   q_coordinates  - The spacial coords in projection axes of the pixel data [u1, u2, u3] (3 x n array)
    %   run_idx        - The run index the pixel originated from (1 x n array)
    %   detector_idx   - The detector group number in the detector listing for the pixels (1 x n array)
    %   energy_idx     - The energy bin numbers (1 x n array)
    %   signal         - The signal array (1 x n array).
    %   variance       - The variance on the signal array (variance i.e. error bar squared) (1 x n array)
    %
    %   num_pixels     - The number of pixels in the data block.
    %   pix_range      - [2x4] array of the range of pixels coordinates in Crystal Cartesian coordinate system.
    %
    %   data           - The raw pixel data - usage of this attribute is discouraged, the structure
    %                    of the return value is not guaranteed.
    %   page_size      - The number of pixels in the currently loaded page.
    %

    properties (Access=private)
        f_accessor_;  % instance of faccess object to access pixel data from file
        tmp_io_handler_;  % a PixelTmpFileHandler object that handles reading/writing of tmp files
        page_number_ = 1;  % the index of the currently loaded page
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
        page_memory_size;
        file_path;  % The file that the pixel data has been read from, empty if no file
        n_pages;
        page_size;  % The number of pixels in the current page
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

            if ~exist('init', 'var') || isempty(init)
                init = zeros(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 0);
            end

            if ~exist('upgrade', 'var')
                upgrade = true;
            end

            if exist('mem_alloc', 'var') && ~isempty(mem_alloc)
                obj.page_memory_size = mem_alloc;
            elseif isa(init, 'PixelDataFileBacked')
                obj.page_memory_size = init.page_memory_size_;
            end

            obj.object_id_ = randi([10, 99999], 1, 1);
            obj.tmp_io_handler_ = PixelTmpFileHandler(obj.object_id_);

            if exist('init', 'var')
                if isstruct(init)
                    obj = obj.loadobj(init);
                elseif isa(init, 'PixelDataFileBacked')
                    if ~isempty(init.f_accessor_)
                        obj = obj.init_from_file_accessor_(init.f_accessor_);
                    end

                    obj.data_ = init.data;
                    obj.num_pixels_ = init.num_pixels;
                    obj.page_dirty_ = init.page_dirty_;
                    obj.dirty_page_edited_ = init.dirty_page_edited_;
                    has_tmp_files = init.tmp_io_handler_.copy_folder(obj.object_id_);
                    if any(has_tmp_files)
                        obj.tmp_io_handler_ = PixelTmpFileHandler(obj.object_id_, has_tmp_files);
                    end
                    obj.move_to_page(init.page_number_);
                elseif ischar(init) || isstring(init)
                    if ~is_file(init)
                        error('HORACE:PixelDataFileBacked:invalid_argument', ...
                              'Cannot find file to load (%s)', init)
                    end

                    init = sqw_formats_factory.instance().get_loader(init);
                    obj = obj.init_from_file_accessor_(init);

                elseif isa(init, 'sqw_file_interface')
                    obj = obj.init_from_file_accessor_(init);

                elseif isnumeric(init)
                    if obj.base_page_size < size(init, 2)
                        error('HORACE:PixelDataFileBacked:invalid_argument', ...
                              'Cannot create file-backed with data larger than a page')
                    end
                    obj.set_raw_data(init);
                    obj.data_ = init;
                    obj.num_pixels_ = size(init, 2);
                    if ~obj.cache_is_empty_()
                        obj.set_page_dirty_(true);
                        obj.write_dirty_page_();
                        obj.reset_changed_coord_range('coordinates');
                    end
                else
                    error('HORACE:PixelDataFileBacked:invalid_argument', ...
                          'Cannot construct PixelDataFileBacked from class (%s)', class(init))
                end

                if any(obj.pix_range == obj.EMPTY_RANGE_, 'all') && upgrade
                    if get(herbert_config, 'log_level') > 0
                        fprintf('*** Recalculating actual pixel range missing in file %s:\n', ...
                                init.filename);
                    end
                    obj.recalc_pix_range();
                end

            else
                obj.page_dirty_ = true;

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
            if ~isscalar(val)
                validateattributes(val, {'numeric'}, {'size', [numel(obj.FIELD_INDEX_MAP_(fld)), obj.page_size]})
            else
                validateattributes(val, {'numeric'}, {'scalar'})
            end
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

        function saveobj(~)
            error('HORACE:PixelData:runtime_error',...
                  'Can not save filebacked PixelData object');
        end

        function has_more = has_more(obj)
        % Returns true if there are subsequent pixels stored in the file that
        % are not held in the current page
        %
        %    >> has_more = pix.has_more();
        %
            has_more = obj.pix_position_ + obj.base_page_size <= obj.num_pixels;
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

            [current_page_num,total_num_pages]=obj.move_to_page(obj.page_number_ + 1, varargin{:});
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

        function page_size = get.page_size(obj)
            % The number of pixels that are held in the current page.
            if obj.num_pixels > 0 && obj.cache_is_empty_()
                % No pixels currently loaded, show the number that will be loaded
                % when a getter is called
                base_pg_size = obj.base_page_size;
                if base_pg_size*obj.page_number_ > obj.num_pixels
                    % In this case we're on the final page and there are fewer
                    % leftover pixels than would be in a full-size page
                    page_size = obj.num_pixels - base_pg_size*(obj.page_number_ - 1);
                else
                    page_size = min(base_pg_size, obj.num_pixels);
                end
            else
                page_size = size(obj.data_, 2);
            end
        end

        function set.page_memory_size(obj, val)
            validateattributes(val, {'numeric'}, {'scalar', 'nonnan', ...
                 '>', PixelDataBase.DATA_POINT_SIZE*PixelDataBase.DEFAULT_NUM_PIX_FIELDS})
            obj.page_memory_size_ = round(val);
        end

        function page_size = get.page_memory_size(obj)
            page_size = obj.page_memory_size_;
        end
    end

    methods (Access = private)

        function obj = load_current_page_if_data_empty_(obj)
            % Check if there's any data in the current page and load a page if not
            %   This function does nothing if pixels are not file-backed.
            if obj.cache_is_empty_() && ~isempty(obj)
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
            is = page_number <= numel(obj.page_dirty_) && obj.page_dirty_(page_number);
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
            if ~exist('page_number', 'var')
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
                field_name = "coordinates";
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
