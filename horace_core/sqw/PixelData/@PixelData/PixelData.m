classdef PixelData < handle
    % PixelData Provides an interface for access to pixel data
    %
    %   This class provides getters and setters for each data column in an SQW
    %   pixel array. You can access the data using the attributes listed below,
    %   using the get_data() method (to retrieve column data) or using the
    %   get_pixels() method (retrieve row data).
    %
    %   Construct this class with an 9 x N array, a file path to an SQW object or
    %   an instance of sqw_binfile_common.
    %
    %   >> pix_data = PixelData(data);
    %   >> pix_data = PixelData('/path/to/sqw.sqw');
    %   >> pix_data = PixelData('/path/to/sqw.sqw', mem_alloc);
    %   >> pix_data = PixelData(faccess_obj);
    %   >> pix_data = PixelData(faccess_obj, mem_alloc);
    %
    %   Constructing via a file or sqw_binfile_common will create a file-backed
    %   data object. No pixel data will be loaded from the file on construction.
    %   Data will be loaded when a getter is called e.g. pix_data.signal. Data will
    %   be loaded in pages such that the data held in memory will not exceed the
    %   size (in bytes) specified by private attribute page_memory_size_ - this can
    %   be set on construction (see mem_alloc above).
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
    %   >> pix_data = PixelData(data)
    %   >> signal = pix_data.signal;
    %
    %  or equivalently:
    %
    %   >> pix_data = PixelData();
    %   >> pix_data.data = data;
    %   >> signal = pix_data.get_data('signal');
    %
    %  To retrieve multiple fields of data, e.g. run_idx and energy_idx, for pixels 1 to 10:
    %
    %   >> pix_data = PixelData(data);
    %   >> signal = pix_data.get_data({'run_idx', 'energy_idx'}, 1:10);
    %
    %  To retrieve data for pixels 1, 4 and 10 (returning another PixelData object):
    %
    %   >> pix_data = PixelData(data);
    %   >> pixel_subset = pix_data.get_pixels([1, 4, 10])
    %
    %  To sum the signal of a file-backed object where the page size is less than
    %  amount of data in the file:
    %
    %   >> pix = PixelData('my_data.sqw')
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
        PIXEL_BLOCK_COLS_ = PixelData.DEFAULT_NUM_PIX_FIELDS;
        %
        dirty_page_edited_ = false;  % true if a dirty page has been edited since it was loaded
        f_accessor_;  % instance of faccess object to access pixel data from file
        file_path_ = '';  % the path to the file backing this object - empty string if all data in memory
        num_pixels_ = 0;  % the number of pixels in the object
        object_id_;  % random unique identifier for this object, used for tmp file names
        page_dirty_ = false;  % array mapping from page_number to whether that page is dirty
        page_memory_size_;  % the maximum amount of memory a page can use
        page_number_ = 1;  % the index of the currently loaded page
        raw_data_ = zeros(PixelData.DEFAULT_NUM_PIX_FIELDS, 0);  % the underlying data cached in the object
        tmp_io_handler_;  % a PixelTmpFileHandler object that handles reading/writing of tmp files
        pix_range_=PixelData.EMPTY_RANGE_; % range of pixels in Crystal Cartesian coordinate system
    end
    
    properties (Constant)
        DATA_POINT_SIZE = 8;  % num bytes in a double
        DEFAULT_NUM_PIX_FIELDS = 9;
        DEFAULT_PAGE_SIZE = realmax;  % this gives no paging by default
    end
    properties (Constant,Hidden)
        % the coordinate range, an empty pixel class has
        EMPTY_RANGE_ = [inf,inf,inf,inf;-inf,-inf,-inf,-inf];
        % the version of the class to store/restore data in Matlab files
        version = 1;
    end
    properties(Constant,Access=private)
        FIELD_INDEX_MAP_ = containers.Map(...
            {'u1', 'u2', 'u3', 'dE', ...
            'coordinates', ...
            'q_coordinates', ...
            'run_idx', ...
            'detector_idx', ...
            'energy_idx', ...
            'signal', ...
            'variance',...
            'all'}, ...
            {1, 2, 3, 4, 1:4, 1:3, 5, 6, 7, 8, 9,1:9});
        % list of the fields, used for exporting PixelData class to
        % structure
        % Does not properly support filebased data. The decision is not to
        % save filebased data into mat files
        fields_to_save_ = {'file_path','data','num_pixels','pix_range'};
    end
    
    properties (Dependent)
        u1; % The 1st dimension of the Crystal Cartesian orientation (1 x n array) [A^-1]
        u2; % The 2nd dimension of the Crystal Cartesian orientation (1 x n array) [A^-1]
        u3; % The 3rd dimension of the Crystal Cartesian orientation (1 x n array) [A^-1]
        dE; % The array of energy deltas of the pixels (1 x n array) [meV]
        
        q_coordinates; % The spatial dimensions of the Crystal Cartesian
        %                orientation (3 x n array)
        coordinates;   % The coordinates of the pixels in the projection axes, i.e.: u1,
        %                u2, u3 and dE (4 x n array)
        
        run_idx; % The run index the pixel originated from (1 x n array)
        detector_idx; % The detector group number in the detector listing for the pixels (1 x n array)
        energy_idx;   % The energy bin numbers (1 x n array)
        
        signal;   % The signal array (1 x n array)
        variance; % The variance on the signal array
        %            (variance i.e. error bar squared) (1 x n array)
        num_pixels;         % The number of pixels in the data block
        
        pix_range; % The range of pixels coordinates in Crystal Cartesian
        % coordinate system. [2x4] array of [min;max] values of pixels
        % coordinates field. If data are file-based and you are setting
        % pixels coordinates, this value may get invalid, as the range
        % never shrinks.
        
        data; % The full raw pixel data block. Usage of this attribute exposes
        % current pixels layout, so when the pixels layout changes in a
        % future, the code using this attribute will change too. So, the usage
        % of this attribute is discouraged as the structure of the return
        % value is not guaranteed in a future.
        
        file_path;  % The file that the pixel data has been read from, empty if no file
        page_size;  % The number of pixels in the current page
        base_page_size;  % The number of pixels that can fit in one page of data
    end
    properties(Dependent,Access=private)
        %
        data_;  % points to raw_data_ but with a layer of validation for setting correct array sizes
        %
        pix_position_;  % the pixel index in the file of the first pixel in the cache
    end
    properties(Access=public,Hidden)
        % Contains the range(min/max value) of a block of pixels,
        % changed by set.pixels methods. Exposed to be used in algorithms,
        % looping over the paged pixels and changing object using
        % coordinate setters to calculate and set-up correct global pixels
        % range in conjunction with set_range method at the end of the loop.
        page_range;
    end
    
    methods (Static)
        
        function obj = cat(varargin)
            % Concatenate the given PixelData objects' pixels. This function performs
            % a straight-forward data concatenation.
            %
            %   >> joined_pix = PixelData.cat(pix_data1, pix_data2);
            %
            % Input:
            % ------
            %   varargin    A cell array of PixelData objects
            %
            % Output:
            % -------
            %   obj         A PixelData object containing all the pixels in the inputted
            %               PixelData objects
            data_cell_array = cellfun(@(p) p.data, varargin, 'UniformOutput', false);
            data = cat(2, data_cell_array{:});
            obj = PixelData(data);
        end
        
        function obj = loadobj(S)
            % Load a PixelData object from a .mat file
            %
            %>> obj = PixelData.loadobj(S)
            % Input:
            % ------
            %   S       A data, produeced by saveobj operation and stored
            %           in .mat file
            % Output:
            % -------
            %   obj     An instance of PixelData object or array of objects
            %
            obj = loadobj_(S);
        end
        
        function validate_mem_alloc(mem_alloc)
            if ~isnumeric(mem_alloc)
                error('HORACE:PixelData:invalid_argument', ...
                    ['Invalid mem_alloc. ''mem_alloc'' must be numeric, ' ...
                    'found class ''%s''.'], class(mem_alloc));
            elseif ~isscalar(mem_alloc)
                error('HORACE:PixelData:invalid_argument', ...
                    ['Invalid mem_alloc. ''mem_alloc'' must be a scalar, ' ...
                    'found size ''%s''.'], mat2str(size(mem_alloc)));
            end
            MIN_RECOMMENDED_PG_SIZE = 100e6;
            bytes_in_pix = sqw_binfile_common.FILE_PIX_SIZE;
            if mem_alloc < bytes_in_pix
                error('HORACE:PixelData:invalid_argument', ...
                    ['Error setting pixel page size. Cannot set page '...
                    'size less than %i bytes, as this is less than one pixel.'], ...
                    bytes_in_pix);
            elseif mem_alloc < MIN_RECOMMENDED_PG_SIZE
                warning('HORACE:PixelData:memory_allocation', ...
                    ['A pixel page size of less than 100MB is not ' ...
                    'recommended. This may degrade performance.']);
            end
        end
    end
    
    methods
        % --- Pixel operations ---
        pix_out = append(obj, pix);
        [mean_signal, mean_variance] = compute_bin_data(obj, npix);
        pix_out = do_binary_op(obj, operand, binary_op, varargin);
        pix_out = do_unary_op(obj, unary_op);
        [ok, mess] = equal_to_tol(obj, other_pix, varargin);
        pix_out = get_data(obj, fields, abs_pix_indices);
        pix_out = get_pix_in_ranges(obj, abs_indices_starts, abs_indices_ends,recalculate_pix_ranges);
        pix_out = get_pixels(obj, abs_pix_indices);
        pix_out = mask(obj, mask_array, npix);
        [page_num, total_number_of_pages] = move_to_page(obj, page_number, varargin);
        pix_out = noisify(obj, varargin);
        obj = recalc_pix_range(obj);
        set_data(obj, fields, data, abs_pix_indices);
        
        
        function obj = PixelData(arg, mem_alloc)
            % Construct a PixelData object from the given data. Default
            % construction initialises the underlying data as an empty (9 x 0)
            % array.
            %
            %   >> obj = PixelData(ones(9, 200))
            %
            %   >> obj = PixelData(200)  % initialise 200 pixels with underlying data set to zero
            %
            %   >> obj = PixelData(file_path)  % initialise pixel data from an sqw file
            %
            %   >> obj = PixelData(faccess_reader)  % initialise pixel data from an sqw file reader
            %
            %   >> obj = PixelData(faccess_reader, mem_alloc)  % set maximum memory allocation
            %
            % Input:
            % ------
            %   arg    A 9 x n matrix, where each row corresponds to a pixel and
            %          the columns correspond to the following:
            %             col 1: u1
            %             col 2: u2
            %             col 3: u3
            %             col 4: dE
            %             col 5: run_idx
            %             col 6: detector_idx
            %             col 7: energy_idx
            %             col 8: signal
            %             col 9: variance
            %
            %  arg    An integer specifying the desired number of pixels. The underlying
            %         data will be filled with zeros.
            %
            %  arg    A path to an SQW file.
            %
            %  arg    An instance of an sqw_binfile_common file reader.
            %
            %  mem_alloc    The maximum amount of memory allocated to hold pixel
            %               data in bytes. If pixels cannot all be held in memory
            %               at one time, they will be loaded from the file
            %               (specified by 'arg') when they are required. This
            %               argument does nothing if the class is constructed with
            %               in-memory data. (Optional)
            %
            if nargin> 0 && isstruct(arg)
                if ~isfield(arg,'version')
                    fnms = fieldnames(arg);
                    if all(ismember(PixelData.fields_to_save_,fnms)) % the current pixdata structure
                        % provided as input
                        if numel(arg) > 1 % the same as saveobj
                            arg = struct('version',PixelData.version,...
                                'array_data',arg);
                        else
                            arg.version = PixelData.version;
                        end
                    end
                    %else: some unknown structure. May be saved earlier without version?
                    % let loadobj check its validity
                end
                obj = PixelData.loadobj(arg);
                return;
            end
            
            obj.object_id_ = polyval(randi([0, 9], 1, 5), 10);
            if exist('mem_alloc', 'var')
                obj.validate_mem_alloc(mem_alloc);
                obj.page_memory_size_ = mem_alloc;
            else
                obj.page_memory_size_ = PixelData.DEFAULT_PAGE_SIZE;
            end
            
            if nargin == 0
                return
            end
            % In memory construction
            if isa(arg, 'PixelData')  % TODO make sure this works with file-backed
                if arg.is_filebacked() && exist(arg.file_path, 'file')
                    % if the file exists we can create a file-backed instance
                    obj = PixelData(arg.file_path, arg.page_memory_size_);
                    obj.page_number_ = arg.page_number_;
                    obj.page_dirty_ = arg.page_dirty_;
                    obj.dirty_page_edited_ = arg.dirty_page_edited_;
                    has_tmp_files = arg.tmp_io_handler_.copy_folder(obj.object_id_);
                    if any(has_tmp_files)
                        obj.tmp_io_handler_ = PixelTmpFileHandler(obj.object_id_, has_tmp_files);
                    end
                else
                    obj.num_pixels_ = size(arg.data, 2);
                end
                obj.data_ = arg.data;
                obj.page_memory_size_ = arg.page_memory_size_;
                obj.reset_changed_coord_range('coordinates')
                return;
            end
            
            if numel(arg) == 1 && isnumeric(arg) && floor(arg) == arg
                % input is an integer
                obj.data_ = zeros(obj.PIXEL_BLOCK_COLS_, arg);
                obj.num_pixels_ = arg;
                obj.pix_range_ = zeros(2,4);
                obj.page_range = zeros(2,4);
                return;
            end
            
            % File-backed construction
            if ischar(arg)
                % input is a file path
                f_accessor = sqw_formats_factory.instance().get_loader(arg);
                obj = obj.init_from_file_accessor_(f_accessor);
                return;
            end
            if isa(arg, 'sqw_file_interface')
                % input is a file accessor
                obj = obj.init_from_file_accessor_(arg);
                if any(obj.pix_range == obj.EMPTY_RANGE_)
                    if config_store.instance().get_value('herbert_config','log_level')>0
                        fprintf('*** Recalculating actual pixel range missing in file %s:\n', ...
                            arg.filename);
                    end
                    obj.recalc_pix_range();                    
                end
                return;
                
            end
            % Input sets underlying data
            if exist('mem_alloc', 'var') && ...
                    (obj.calculate_page_size_(mem_alloc) < size(arg, 2))
                error('HORACE:PixelData:invalid_argument', ...
                    ['The size of the input array cannot exceed the given ' ...
                    'memory_allocation.']);
            end
            obj.data_ = arg;
            obj.reset_changed_coord_range('coordinates')
            obj.num_pixels_ = size(arg, 2);
            obj.tmp_io_handler_ = PixelTmpFileHandler(obj.object_id_);
        end
        
        % --- Operator overrides ---
        function delete(obj)
            % Class destructor to delete any temporary files
            if ~isempty(obj.tmp_io_handler_)
                obj.tmp_io_handler_.delete_files();
            end
        end
        %
        function data=saveobj(obj)
            if obj.is_filebacked()
                error('HORACE:PixelData:runtime_error',...
                    'Can not save filebacked PixelData object');
            end
            data = struct(obj);
            if numel(obj)>1
                data = struct('version',PixelData.version,...
                    'array_data',data);
            else
                data.version = obj.version;
            end
        end
        
        function is_empty = isempty(obj)
            % Return true if the PixelData object holds no pixel data
            is_empty = obj.num_pixels == 0;
        end
        
        function pix_copy = copy(obj)
            % Make an independent copy of this object
            %  This method simply constructs a new PixelData instance by calling
            %  the constructor with the input object as an argument. Because of
            %  this, any properties that need to be explicitly copied must be
            %  copied within this classes "copy-constructor".
            pix_copy = PixelData(obj);
        end
        
        % --- Data management ---
        function has_more = has_more(obj)
            % Returns true if there are subsequent pixels stored in the file that
            % are not held in the current page
            %
            %    >> has_more = pix.has_more();
            %
            has_more = false;
            if ~obj.is_filebacked()
                return;
            end
            if obj.page_size == 0 && obj.num_pixels > obj.base_page_size
                % If nothing has been loaded into the cache yet (page_size == 0),
                % the object acts as though the first page has been loaded. So
                % return true if there's more than one page worth of pixels
                has_more = true;
            else
                has_more = obj.pix_position_ + obj.base_page_size  <= obj.num_pixels;
            end
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
            current_page_num = 1;
            total_num_pages = 1;
            if obj.is_filebacked()
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
        end
        
        function obj = move_to_first_page(obj)
            % Reset the object to point to the first page of pixel data in the file
            % and clear the current cache
            %  This function does nothing if pixels are not file-backed.
            %
            obj.move_to_page(1);
        end
        
        % --- Getters / Setters ---
        function pixel_data = get.data(obj)
            obj = obj.load_current_page_if_data_empty_();
            pixel_data = obj.data_;
        end
        
        function set.data(obj, pixel_data)
            % This setter provides rules for public facing edits to the cached data
            if obj.page_size == 0
                % no pixels loaded, get our expected page size
                required_page_size = min(obj.base_page_size, obj.num_pixels);
            else
                required_page_size = obj.page_size;
            end
            
            if size(pixel_data, 2) ~= required_page_size
                msg = ['Cannot set pixel data, invalid dimensions. Axis 2 ' ...
                    'must have num elements matching current page size (%i), ' ...
                    'found ''%i''.'];
                error('HORACE:PixelData:invalid_argument', msg,...
                    required_page_size, size(pixel_data, 2));
            end
            obj.data_ = pixel_data;
            obj.reset_changed_coord_range('coordinates');
            obj.set_page_dirty_(true);
        end
        
        function data = get.data_(obj)
            data = obj.raw_data_;
        end
        
        function set.data_(obj, pixel_data)
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
            %obj.num_pixels_ = size(pixel_data,2); % breaks filebased
            %PixelData
        end
        
        function u1 = get.u1(obj)
            obj = obj.load_current_page_if_data_empty_();
            u1 = obj.data(obj.FIELD_INDEX_MAP_('u1'), :);
        end
        
        function set.u1(obj, u1)
            obj = obj.load_current_page_if_data_empty_();
            obj.data(obj.FIELD_INDEX_MAP_('u1'), :) = u1;
            obj.reset_changed_coord_range('u1');
            obj.set_page_dirty_(true);
        end
        
        function u2 = get.u2(obj)
            obj = obj.load_current_page_if_data_empty_();
            u2 = obj.data(obj.FIELD_INDEX_MAP_('u2'), :);
        end
        
        function set.u2(obj, u2)
            obj = obj.load_current_page_if_data_empty_();
            obj.data(obj.FIELD_INDEX_MAP_('u2'), :) = u2;
            obj.reset_changed_coord_range('u2');
            obj.set_page_dirty_(true);
        end
        
        function u3 = get.u3(obj)
            obj = obj.load_current_page_if_data_empty_();
            u3 = obj.data(obj.FIELD_INDEX_MAP_('u3'), :);
        end
        
        function set.u3(obj, u3)
            obj = obj.load_current_page_if_data_empty_();
            obj.data(obj.FIELD_INDEX_MAP_('u3'), :) = u3;
            obj.reset_changed_coord_range('u3');
            obj.set_page_dirty_(true);
        end
        
        function dE = get.dE(obj)
            obj = obj.load_current_page_if_data_empty_();
            dE = obj.data(obj.FIELD_INDEX_MAP_('dE'), :);
        end
        
        function set.dE(obj, dE)
            obj = obj.load_current_page_if_data_empty_();
            obj.data(obj.FIELD_INDEX_MAP_('dE'), :) = dE;
            obj.reset_changed_coord_range('dE');
            obj.set_page_dirty_(true);
        end
        
        function coord_data = get.coordinates(obj)
            obj = obj.load_current_page_if_data_empty_();
            coord_data = obj.data(obj.FIELD_INDEX_MAP_('coordinates'), :);
        end
        
        function set.coordinates(obj, coordinates)
            obj = obj.load_current_page_if_data_empty_();
            obj.data(obj.FIELD_INDEX_MAP_('coordinates'), :) = coordinates;
            obj.reset_changed_coord_range('coordinates');
            obj.set_page_dirty_(true);
        end
        
        function coord_data = get.q_coordinates(obj)
            obj = obj.load_current_page_if_data_empty_();
            coord_data = obj.data(obj.FIELD_INDEX_MAP_('q_coordinates'), :);
        end
        
        function set.q_coordinates(obj, q_coordinates)
            obj = obj.load_current_page_if_data_empty_();
            obj.data(obj.FIELD_INDEX_MAP_('q_coordinates'), :) = q_coordinates;
            obj.reset_changed_coord_range('q_coordinates');
            obj.set_page_dirty_(true);
        end
        
        function run_index = get.run_idx(obj)
            obj = obj.load_current_page_if_data_empty_();
            run_index = obj.data(obj.FIELD_INDEX_MAP_('run_idx'), :);
        end
        
        function set.run_idx(obj, iruns)
            obj = obj.load_current_page_if_data_empty_();
            obj.data(obj.FIELD_INDEX_MAP_('run_idx'), :) = iruns;
            obj.set_page_dirty_(true);
        end
        
        function detector_index = get.detector_idx(obj)
            obj = obj.load_current_page_if_data_empty_();
            detector_index = obj.data(obj.FIELD_INDEX_MAP_('detector_idx'), :);
        end
        
        function set.detector_idx(obj, detector_indices)
            obj = obj.load_current_page_if_data_empty_();
            obj.data(obj.FIELD_INDEX_MAP_('detector_idx'), :) = detector_indices;
            obj.set_page_dirty_(true);
        end
        
        function detector_index = get.energy_idx(obj)
            obj = obj.load_current_page_if_data_empty_();
            detector_index = obj.data(obj.FIELD_INDEX_MAP_('energy_idx'), :);
        end
        
        function set.energy_idx(obj, energies)
            obj = obj.load_current_page_if_data_empty_();
            obj.data(obj.FIELD_INDEX_MAP_('energy_idx'), :) = energies;
            obj.set_page_dirty_(true);
        end
        
        function signal = get.signal(obj)
            obj = obj.load_current_page_if_data_empty_();
            signal = obj.data(obj.FIELD_INDEX_MAP_('signal'), :);
        end
        
        function set.signal(obj, signal)
            obj = obj.load_current_page_if_data_empty_();
            obj.data(obj.FIELD_INDEX_MAP_('signal'), :) = signal;
            obj.set_page_dirty_(true);
        end
        
        function variance = get.variance(obj)
            obj = obj.load_current_page_if_data_empty_();
            variance = obj.data(obj.FIELD_INDEX_MAP_('variance'), :);
        end
        
        function set.variance(obj, variance)
            obj = obj.load_current_page_if_data_empty_();
            obj.data(obj.FIELD_INDEX_MAP_('variance'), :) = variance;
            obj.set_page_dirty_(true);
        end
        
        function num_pix = get.num_pixels(obj)
            num_pix = obj.num_pixels_;
        end
        
        function file_path = get.file_path(obj)
            file_path = obj.file_path_;
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
        
        function pix_position = get.pix_position_(obj)
            pix_position = (obj.page_number_ - 1)*obj.base_page_size + 1;
        end
        
        function page_size = get.base_page_size(obj)
            page_size = obj.calculate_page_size_(obj.page_memory_size_);
        end
        
        function range = get.pix_range(obj)
            range  = obj.pix_range_;
        end
        %
        function set_range(obj,pix_range)
            % Function allows to set the pixels range (min/max values of
            % pixels coordinates)
            %
            % Use with caution!!! No checks that the set range is the
            % correct range for pixels, holded by the class are
            % performed, while subsequent algorithms may rely on pix range
            % to be correct. A out-of memory write can occur during rebinning
            % if the range is smaller, then the actual range.
            %
            % Necessary to set up the pixel range when filebased
            % pixels are modified by algorithm and correct range
            % calculations are expensive
            %
            if any(size(pix_range) ~=[2,4])
                error('HORACE:PixelData:InvalidArgument',...
                    'pixel_range should be [2x4] array');
            end
            obj.pix_range_ = pix_range;
        end
        
        function is = is_filebacked(obj)
            % Return true if the pixel data is backed by a file or files. Returns
            % false if all pixel data is held in memory
            %
            if numel(obj) > 1
                is = arrayfun(@(x)(~isempty(x.f_accessor_) || x.get_num_pages_() > 1),...
                    obj,'UniformOutput',true);
                is = any(reshape(is,1,numel(is)));
            else
                is = ~isempty(obj.f_accessor_) || obj.get_num_pages_() > 1;
            end
        end
        %
        function st = struct(obj)
            % convert object into saveable and serializable structure
            %
            flds = obj.fields_to_save_;
            
            cell_dat = cell(numel(flds),numel(obj));
            for j=1:numel(obj)
                for i=1:numel(flds)
                    fldn = flds{i};
                    cell_dat{i,j} = obj(j).(fldn);
                end
            end
            st = cell2struct(cell_dat,flds,1);
            if numel(obj)>1
                st = reshape(st,size(obj));
            end
        end
    end
    
    methods (Access=private)
        
        function obj = init_from_file_accessor_(obj, f_accessor)
            % Initialise a PixelData object from a file accessor
            obj.f_accessor_ = f_accessor;
            obj.file_path_ = fullfile(obj.f_accessor_.filepath, ...
                obj.f_accessor_.filename);
            obj.page_number_ = 1;
            obj.num_pixels_ = double(obj.f_accessor_.npixels);
            %
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
            
            obj.data_ = obj.f_accessor_.get_pix(pix_idx_start, pix_idx_end);
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
            % set appropriate range of pixel coordinates.
            % The coordinates are defined by the selected field
            %
            % Sets up the property page_range defining the range of block
            % of pixels chaned at current iteration.
            %
            obj = obj.load_current_page_if_data_empty_();
            if isempty(obj.raw_data_)
                obj.pix_range_   = PixelData.EMPTY_RANGE_;
                obj.page_range = PixelData.EMPTY_RANGE_;
                return
            end
            ind = obj.FIELD_INDEX_MAP_(field_name);
            
            loc_range = [min(obj.raw_data_(ind,:),[],2),max(obj.raw_data_(ind,:),[],2)]';
            % is filebacked and pages do not fit memory
            if  ~isempty(obj.f_accessor_) && obj.get_num_pages_() > 1
                % this may break things down, as the range only expands
                range = [min(obj.pix_range_(1,ind),loc_range(1,:));...
                    max(obj.pix_range_(2,ind),loc_range(2,:))];
            else
                range = loc_range;
            end
            obj.pix_range_(:,ind) = range;
            obj.page_range(:,ind) = loc_range;
        end
    end
    
end
