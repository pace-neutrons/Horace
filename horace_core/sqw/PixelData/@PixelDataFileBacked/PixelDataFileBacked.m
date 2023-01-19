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

    properties (Constant, Access=private)
        TMP_FILE_BASE_NAME = 'sqw_pix%09d';
        TMP_FILE_EXT = '.tmp_sqw';
        FILE_DATA_FORMAT_ = 'single';
        SIZE_OF_FLOAT = 4;
    end

    properties (Access=private)
        f_accessor_;  % instance of faccess object to access pixel data from file
        page_number_ = 1;  % the index of the currently loaded page
        has_tmp_file = false;
        offset_ = 0;
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
        page_memory_size_;
        page_edited = false;
    end

    properties (Dependent)
        page_memory_size;
        n_pages;
        page_size;  % The number of pixels in the current page
    end

    properties(Dependent, Access=protected)
        % the pixel index in the file of the first pixel in the cache
        pix_position_;

        % The location of the intermediary file which will be created
        tmp_pix_full_filename_;

        % The location of the temporary file which will be created
        pix_full_filename_;
    end

    methods
        function obj = PixelDataFileBacked(init, mem_alloc, upgrade)
            % Construct a File-backed PixelData object from the given data. Default
            % construction initialises the underlying data as an empty (9 x 0)
            % array.
            obj.page_memory_size_ = ...
                config_store.instance().get_value('hor_config','mem_chunk_size');
            if ~exist('init', 'var') || isempty(init)
                init = zeros(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 0);
            end

            if ~exist('upgrade', 'var')
                upgrade = true;
            end

            obj.object_id_ = randi([1, 999999998], 1, 1);

            if exist('mem_alloc', 'var') && ~isempty(mem_alloc)
                obj.page_memory_size = mem_alloc;
            elseif isa(init, 'PixelDataFileBacked')
                obj.page_memory_size = init.page_memory_size_;
            end

            if exist('init', 'var')
                if isstruct(init)
                    obj = obj.loadobj(init);
                elseif isa(init, 'PixelDataFileBacked')
                    %% TODO: #928 Cleanup when tmp_file concept obsolete
                    obj.has_tmp_file = init.has_tmp_file;
                    if obj.has_tmp_file
                        %%                         obj.full_filename_ = init.tmp_full_filename_;
                        copyfile(init.pix_full_filename_, obj.pix_full_filename_);
                        obj.num_pixels_ = init.num_pixels;
                        obj.pix_range = init.pix_range;
                        obj.data_ = init.data_;
                        obj.has_tmp_file = true;
                    elseif ~isempty(init.f_accessor_)
                        obj = obj.init_from_file_accessor_(init.f_accessor_);
                    end

                    obj.num_pixels_ = init.num_pixels;
                    obj.pix_range = init.pix_range;
                    obj.data_ = init.data;
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
                    obj=obj.set_raw_data(init);
                    obj.data_ = init;
                    obj.num_pixels_ = size(init, 2);
                    if ~obj.cache_is_empty_()
                        obj=obj.reset_changed_coord_range('coordinates');
                    end
                else
                    error('HORACE:PixelDataFileBacked:invalid_argument', ...
                        'Cannot construct PixelDataFileBacked from class (%s)', class(init))
                end

                if any(obj.data_range == obj.EMPTY_RANGE_, 'all') && upgrade
                    if get(herbert_config, 'log_level') > 0
                        if any(isprop(init,'filename'))
                            fprintf('*** Recalculating actual pixel range missing in file %s:\n', ...
                                init.filename);
                        end
                    end
                    obj=obj.recalc_data_range();
                end

            end

        end

        function data = get_raw_data(obj)
            data = obj.data_;
        end

        function obj=set_raw_data(obj, pixel_data)
            % This setter provides rules for internally setting cached data
            %  This is the only method that should ever touch obj.raw_data_

            % The need for multiple layers of getters/setters for the raw data
            % should be removed when the public facing getters/setters are removed.
            if isempty(pixel_data)
                pixel_data = zeros(9, 0);
            end
            validateattributes(pixel_data, {'numeric'}, {'nrows', obj.PIXEL_BLOCK_COLS_})
            obj.data_ = pixel_data;
        end

        function prp = get_prop(obj, fld)
        %% TODO: Check can go once finalise complete as tmpfile becomes realfile immediately
            if ~obj.has_tmp_file
                obj.load_page(obj.page_number_);
                prp = obj.data_(obj.FIELD_INDEX_MAP_(fld), :);
                if ~isempty(obj.f_accessor_)
                    obj.data_ = [];
                end
            else
                data_map = obj.get_memmap_handle();
                [pix_idx_start, pix_idx_end] = obj.get_page_idx_(obj.page_number_);
                prp = double(data_map.data.data(obj.FIELD_INDEX_MAP_(fld), ...
                                    pix_idx_start:pix_idx_end));
            end
        end

        function prp = get_all_prop(obj, fld)
            if iscellstr(fld)
                flds = cellfun(@(x) obj.FIELD_INDEX_MAP_(x), fld, 'UniformOutput', false);
                flds = unique([flds{:}]);
            else
                flds = obj.FIELD_INDEX_MAP_(fld);
            end
            %% TODO: Check can go once finalise complete as tmpfile becomes realfile immediately
            if ~obj.has_tmp_file
                prp = zeros(numel(flds), obj.num_pixels);
                for i = 1:obj.n_pages
                    [pix_idx_start, pix_idx_end] = obj.get_page_idx_(i);
                    obj.load_page(i);
                    prp(1:numel(flds), pix_idx_start:pix_idx_end) = obj.data(flds, :);
                end
            else
                data_map = obj.get_memmap_handle();
                prp = double(data_map.data.data(flds, :));
            end
        end

        function obj=set_all_prop(obj, fld, val)
            flds = obj.FIELD_INDEX_MAP_(fld);
            fid = obj.get_new_handle();
            try
                if ~isscalar(val)
                    validateattributes(val, {'numeric'}, {'size', [numel(flds), obj.num_pixels]})
                    for i = 1:obj.n_pages
                        obj.load_page(i);
                        [start_idx, end_idx] = obj.get_page_idx_(i);
                        obj.data_(flds, :) = val(start_idx:end_idx);
                        obj.format_dump_data(fid);
                    end


                else
                    validateattributes(val, {'numeric'}, {'scalar'})

                    for i = 1:obj.n_pages
                        obj.load_page(i);
                        obj.data_(flds, :) = val;
                        obj.format_dump_data(fid);
                    end

                end
                obj.finalise(fid);

            catch ME
                fclose(fid);
                delete(obj.tmp_pix_full_filename_);
                rethrow(ME);
            end

            obj=obj.reset_changed_coord_range(fld);
        end


        % --- Operator overrides ---
        function delete(obj)
            % Class destructor to delete any temporary file
            if is_file(obj.tmp_pix_full_filename_)
                delete(obj.tmp_pix_full_filename_);
            end
            if is_file(obj.pix_full_filename_)
                delete(obj.pix_full_filename_);
            end
            %%             if ~isempty(obj.tmp_io_handler_)
            %%                 obj.tmp_io_handler_.delete_file();
            %%             end
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

            [current_page_num,total_num_pages] = ...
                obj.move_to_page(obj.page_number_ + 1, varargin{:});
        end

        function pix_position = get.pix_position_(obj)
            pix_position = obj.get_page_start_(obj.page_number_);
        end

        function np = get.n_pages(obj)
            np = max(ceil(obj.num_pixels_/obj.page_memory_size_),1);
        end

        function page_size = get.page_size(obj)
            % The number of pixels that are held in the current page.
            if ~obj.cache_is_empty_()  % Size of currently loaded pix
                page_size = size(obj.data_, 2);
            else
                % No pixels currently loaded, show the number that will be loaded
                % when a getter is called
                page_size = obj.get_npix_on_page(obj.page_number_);
            end
        end

        function page_size = get.page_memory_size(obj)
            page_size = obj.page_memory_size_;
        end

        function set.page_memory_size(obj, val)
            validateattributes(val, {'numeric'}, {'scalar', 'nonnan', 'positive'})

            obj.page_memory_size_ = round(val);
            %% Keep synchronised
            %%             obj.tmp_io_handler_.page_size = obj.page_memory_size_;
        end
    end

    % -----------------------------------------------------------
    % Tmp file handling

    methods
        function full_filename = get.tmp_pix_full_filename_(obj)
            % Generate the file path to the intermediary file with the given page number

            pc = parallel_config;
            file_name = sprintf([obj.TMP_FILE_BASE_NAME, '_', obj.TMP_FILE_EXT], obj.object_id_);
            full_filename = fullfile(pc.working_directory, file_name);
        end

        function full_filename = get.pix_full_filename_(obj)
            % Generate the file path to the tmp file with the given page number

            pc = parallel_config;
            file_name = sprintf([obj.TMP_FILE_BASE_NAME, obj.TMP_FILE_EXT], obj.object_id_);
            full_filename = fullfile(pc.working_directory, file_name);
        end

        function data = get_memmap_handle(obj)
            data = memmapfile(obj.full_filename, ...
                'format', {'single' [obj.PIXEL_BLOCK_COLS_, obj.num_pixels], 'data'}, ...
                'writable', false, ...
                'offset', obj.offset_ ...
                );
        end

        function fid = get_append_handle(obj)
            fid = fopen(obj.tmp_pix_full_filename_, 'wb+');
        end

        function fid = get_new_handle(obj)
            fid = fopen(obj.tmp_pix_full_filename_, 'wb');
            %% TODO: WRITE HEADERS
            %             app_header = struct('appname', 'horace', ...
            %                                 'version', 1, ...
            %                                 'sqw_type', uint32(true), ...
            %                                 'num_dim', uint32(4), ...
            %                                 )
            %             write(fid, serialise(app_header), 'uint8');
            %             bat = blockAllocationTable()
            %             write(bat)
            %             obj.offset_ = sizeof(bat) + sizeof(header)
        end

        function format_dump_data(obj, fid)
            fwrite(fid, obj.data_, obj.FILE_DATA_FORMAT_);
        end

        function finalise(obj, fid)

            %% TODO: Update headers
            fclose(fid);
            obj.has_tmp_file = true; % Must come first or will overwrite original
            movefile(obj.tmp_pix_full_filename_, obj.full_filename);
            % Clear data
            obj.recalc_pix_range();
            obj.data_ = [];
            %% TODO: WITH HEADERS, RELOAD
            %             init = sqw_formats_factory.instance().get_loader(init);
            %             obj = obj.init_from_file_accessor_(init);
        end


    end

    methods(Hidden)
        function fid = dump_all_pixels_(obj, fid)
            % Dump all pixels to tmp_file used for initialising tmp file
            % most operations operate and change the entire file

            if ~exist('fid', 'var')
                fid = obj.get_new_handle();
            end

            % Store current (potentially modified) data
            obj.load_current_page_if_data_empty_();
            pn = obj.page_number_;
            data = obj.data_;

            for i = 1:obj.n_pages
                if i == pn
                    obj.data_ = data;
                else
                    obj.load_page(i);
                end
                obj.format_dump_data(fid);
            end

            % If we're not returning fid, close it
            % otherwise assuming it will be finalised elsewhere
            if nargout == 0
                obj.finalise(fid);
            end

        end
    end

    methods (Access = private)
        function loc = get_page_start_(obj, page_number)
            loc = (page_number - 1)*obj.base_page_size + 1;
        end

        function page_size = get_npix_on_page(obj, page_number)
            base_pg_size = obj.base_page_size;
            if page_number == obj.n_pages
                % In this case we're on the final page and there are fewer
                % leftover pixels than would be in a full-size page
                page_size = obj.num_pixels - base_pg_size*(page_number - 1);
            else
                page_size = base_pg_size;
            end
        end

        function num_pages = get_num_pages_(obj)
            num_pages = max(ceil(obj.num_pixels/obj.base_page_size), 1);
        end

        function obj = load_current_page_if_data_empty_(obj)
            % Check if there's any data in the current page and load a page if not
            %   This function does nothing if pixels are not file-backed.
            if obj.cache_is_empty_() && ~isempty(obj)
                obj = obj.load_page(obj.page_number_);
            end
        end

        function obj = load_page(obj, page_number)
            % Load the data for the given page index

            %% TODO: Check can go once finalise complete as tmpfile becomes realfile immediately
            if ~obj.has_tmp_file
                obj.data_ = obj.load_clean_page_(page_number);
            else
                obj.data_ = obj.load_dirty_page_(page_number);
            end
            obj.page_number_ = page_number;
        end

        function data = load_clean_page_(obj, page_number)
            % Load the given page of data from the sqw file backing this object
            [pix_idx_start, pix_idx_end] = obj.get_page_idx_(page_number);
            if ~isempty(obj.f_accessor_)
                data = obj.f_accessor_.get_raw_pix(pix_idx_start, pix_idx_end);
            else % No pages to load
                data = obj.data_;
            end
        end

        %% TODO: Can go when dirty pages no longer exist
        function data = load_dirty_page_(obj, page_number)
            data_map = obj.get_memmap_handle();
            [pix_idx_start, pix_idx_end] = obj.get_page_idx_(page_number);
            data = double(data_map.data.data(:, pix_idx_start:pix_idx_end));
        end

        function [pix_idx_start, pix_idx_end] = get_page_idx_(obj, page_number)
            pix_idx_start = obj.get_page_start_(page_number);
            if obj.num_pixels > 0 && pix_idx_start > obj.num_pixels
                error('HORACE:PixelData:runtime_error', ...
                    'pix_idx_start exceeds number of pixels in file. %i >= %i', ...
                    pix_idx_start, obj.num_pixels);
            end
            % Get the index of the final pixel to read given the maximum page size
            pix_idx_end = min(pix_idx_start + obj.get_npix_on_page(page_number) - 1, ...
                obj.num_pixels);
        end

    end
    methods(Access=protected)
        function obj = set_full_filename(obj,val)
            % main part of file setter. Need checks/modification
            obj.tmp_io_handler_.move_file(val);
            obj.full_filename_ = val;
        end
        function full_filename = get_full_filename(obj)
            %% TODO Check to go when headers working
            if obj.has_tmp_file
                full_filename = obj.pix_full_filename_;
            else
                full_filename = obj.full_filename_;
            end
        end

    end


    methods (Access = protected)
        %------------------------------------------------------------------
        function obj=set_data_wrap(obj,val)
            % main part of pix_data_wrap setter overloaded for
            % PixDataMemory class
            if ~isa(val,'pix_data')
                error('HORACE:PixelDataMemory:invalid_argument', ...
                    'pix_data_wrap property can be set by pix_data class instance only. Provided class is: %s', ...
                    class(val));
            end
            obj.data_ = val.data;
        end
        function val = get_data_wrap(obj)
            % main part of pix_data_wrap getter overloaded for
            % PixDataMemory class
            val = pix_data();
            val.data = obj.data;
        end

        function p = get_prop(obj, fld)
            %% TODO: Check can go once finalise complete as tmpfile becomes realfile immediately
            if ~obj.has_tmp_file
                obj=obj.load_page(obj.page_number_);
                prp = obj.data_(obj.FIELD_INDEX_MAP_(fld), :);
                if ~isempty(obj.f_accessor_)
                    obj.data_ = [];
                end
            else
                data_map = obj.get_memmap_handle();
                [pix_idx_start, pix_idx_end] = obj.get_page_idx_(obj.page_number_);
                prp = double(data_map.data.data(obj.FIELD_INDEX_MAP_(fld), ...
                    pix_idx_start:pix_idx_end));
            end
        end

        function obj=set_prop(obj, fld, val)
            flds = obj.FIELD_INDEX_MAP_(fld);

            if ~isscalar(val)
                validateattributes(val, {'numeric'}, {'size', [numel(flds), obj.page_size]})
            else
                validateattributes(val, {'numeric'}, {'scalar'})
            end

            obj=obj.load_current_page_if_data_empty_();
            obj.data_(flds, :) = val;
            if ismember(fld, ["u1", "u2", "u3", "dE", "q_coordinates", "coordinates", "all"])
                obj=obj.reset_changed_coord_range(fld);
            end

        end

        function is = cache_is_empty_(obj)
            % Return true if no pixels are currently held in memory
            is = isempty(obj.data_);
        end

        function obj = init_from_file_accessor_(obj, f_accessor)
            % Initialise a PixelData object from a file accessor
            obj.f_accessor_ = f_accessor;
            obj.full_filename_ = obj.f_accessor_.full_filename;
            obj.page_number_ = 1;
            obj.num_pixels_ = double(obj.f_accessor_.npixels);
            obj.data();
            obj.pix_range_ = obj.f_accessor_.get_pix_range();
        end

        function obj=reset_changed_coord_range(obj,field_name)
            % Recalculate and set appropriate range of pixel coordinates.
            % The coordinates are defined by the selected field
            %
            % Sets up the property page_range defining the range of block
            % of pixels chaned at current iteration.
            %
            obj = obj.load_current_page_if_data_empty_();
            if isempty(obj.data_)
                obj.pix_range_   = PixelDataBase.EMPTY_RANGE_;
                obj.page_range = [PixelDataBase.EMPTY_RANGE_,PixelDataBase.EMPTY_S_RANGE_];
                return
            end
            ind = obj.FIELD_INDEX_MAP_(field_name);

            loc_range = [min(obj.data_(ind,:),[],2),max(obj.data_(ind,:),[],2)]';
            obj.page_range(:,ind) = loc_range;

            range = [min(glob_range(1,ind),loc_range(1,:));...
                max(glob_range(2,ind),loc_range(2,:))]';


            is_srange = ind>4;
            coord_ind = ind(~is_srange);
            sig_ind   = ind(is_srange);
            obj.pix_range_(:,coord_ind) = range(:,~is_srange);
            obj.sig_range_(:,sig_ind)   = range(:, is_srange);

        end
    end

end
