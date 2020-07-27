classdef PixelData < handle
% PixelData Provides an interface for access to pixel data
%
%   This class provides getters and setters for each data column in an SQW
%   pixel array. You can access the data using the attributes listed below,
%   using the get_data() method (to retrive column data) or using the
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
% Attributes:
%   u1, u2, u3     The 1st, 2nd and 3rd dimension of the crystal coordinates in projection axes, units are per Angstrom (1 x n arrays)
%   dE             The energy deltas of the pixels in meV (1 x n array)
%   coordinates    The coords in projection axes of the pixel data [u1, u2, u3, dE] (4 x n array)
%   q_coordinates  The spacial coords in projection axes of the pixel data [u1, u2, u3] (3 x n array)
%   run_idx        The run index the pixel originated from (1 x n array)
%   detector_idx   The detector group number in the detector listing for the pixels (1 x n array)
%   energy_idx     The energy bin numbers (1 x n array)
%   signal         The signal array (1 x n array)
%   variance       The variance on the signal array (variance i.e. error bar squared) (1 x n array)
%   num_pixels     The number of pixels in the data block
%   data           The raw pixel data - usage of this attribute is discouraged, the structure
%                  of the return value is not guaranteed
%   page_size      The number of pixels in the currently loaded page
%
properties (Access=private)
    FIELD_INDEX_MAP_ = containers.Map(...
        {'u1', 'u2', 'u3', 'dE', ...
         'coordinates', ...
         'q_coordinates', ...
         'run_idx', ...
         'detector_idx', ...
         'energy_idx', ...
         'signal', ...
         'variance'}, ...
        {1, 2, 3, 4, 1:4, 1:3, 5, 6, 7, 8, 9});
    PIXEL_BLOCK_COLS_ = PixelData.DEFAULT_NUM_PIX_FIELDS;

    dirty_page_edited_ = false;  % true if a dirty page has been edited since it was loaded
    f_accessor_;  % instance of faccess object to access pixel data from file
    file_path_ = '';  % the path to the file backing this object - empty string if all data in memory
    num_pixels_ = 0;  % the number of pixels in the object
    object_id_;  % random unique identifier for this object, used for tmp file names
    page_dirty_ = false;  % array mapping from page_number to whether that page is dirty
    page_memory_size_;  % the maximum amount of memory a page can use
    page_number_ = 1;  % the index of the currently loaded page
    raw_data_ = zeros(9, 0);  % the underlying data cached in the object
    tmp_io_handler_;  % a PixelTmpFileHandler object that handles reading/writing of tmp files
end

properties (Constant)
    DEFAULT_NUM_PIX_FIELDS = 9;
    DATA_POINT_SIZE = 8;  % num bytes in a float
end

properties (Dependent, Access=private)
    data_;  % points to raw_data_ but with a layer of validation for setting correct array sizes
    max_page_size_;  % the maximum number of pixels that can fie in the page memory size
    pix_position_;  % the pixel index in the file of the first pixel in the cache
end

properties (Dependent)
    % Return the 1st, 2nd and 3rd dimension of the crystal cartestian orientation (1 x n arrays) [A^-1]
    u1; u2; u3;

    % Return the spatial dimensions of the crystal cartestian orientation (3 x n array)
    q_coordinates;

    % Returns the array of energy deltas of the pixels (1 x n array) [meV]
    dE;

    % Returns the coordinates of the pixels in the projection axes, i.e.: u1,
    % u2, u3 and dE (4 x n array)
    coordinates;

    % The run index the pixel originated from (1 x n array)
    run_idx;

    % The detector group number in the detector listing for the pixels (1 x n array)
    detector_idx;

    % The energy bin numbers (1 x n array)
    energy_idx;

    % The signal array (1 x n array)
    signal;

    % The variance on the signal array (variance i.e. error bar squared) (1 x n array)
    variance;

    % The number of pixels in the data block
    num_pixels;

    % Returns the full raw pixel data block usage of this attribute is discouraged, the structure of the return value is not guaranteed
    data;

    % The file that the pixel data has been read from, empty if no file
    file_path;

    % The number of pixels in the current page
    page_size;
end

methods (Static)

    function obj = cat(varargin)
        % Concatentate the given PixelData objects' pixels. This function performs
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
        %   >> obj = loadobj(S)
        %
        % Input:
        % ------
        %   S       An instance of this object
        %
        % Output:
        % -------
        %   obj     An instance of this object
        %
        if isempty(S.page_memory_size_)
            % This if statement allows us to load old PixelData objects that
            % were saved in .mat files that do not have the 'page_memory_size_'
            % property
            S.page_memory_size_ = get(hor_config, 'pixel_page_size');
        end
        obj = PixelData(S);
    end

    function validate_mem_alloc(mem_alloc)
        MIN_RECOMMENDED_PG_SIZE = 100e6;
        bytes_in_pix = PixelData.DATA_POINT_SIZE*PixelData.DEFAULT_NUM_PIX_FIELDS;
        if mem_alloc < bytes_in_pix
            error('PIXELDATA:validate_mem_alloc', ...
                  ['Error setting pixel page size. Cannot set page '...
                   'size less than %i bytes, as this is less than one pixel.'], ...
                  bytes_in_pix);
        elseif mem_alloc < MIN_RECOMMENDED_PG_SIZE
            warning('PIXELDATA:validate_mem_alloc', ...
                    ['A pixel page size of less than 100MB is not ' ...
                     'recommended. This may degrade performance.']);
        end
    end

end

methods

    % --- Pixel operations ---
    [mean_signal, mean_variance] = compute_bin_data(obj, npix)
    obj = do_binary_op(obj, operand, binary_op, flip);
    pix_out = do_unary_op(obj, unary_op);
    pix_out = append(obj, pix);
    pix_out = mask(obj, mask_array, npix);

    function obj = PixelData(arg, mem_alloc)
        % Construct a PixelData object from the given data. Default
        % construction initialises the underlying data as an empty (9 x 0)
        % array.
        %
        %   >> obj = PixelData(ones(9, 200))
        %
        %   >> obj = PixelData(200)  % intialise 200 pixels with underlying data set to zero
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
        %         data will be filled with zeros
        %
        %  arg    A path to an SQW file.
        %
        %  arg    An instance of an sqw_binfile_common file reader.
        %
        %  mem_alloc    The maximum amount of memory allocated to hold pixel
        %               data in bytes. If pixels cannot all be held in memory
        %               at one time, they will be loaded from the file
        %               (specified by 'arg') when they are required. This
        %               argument does nothing if the class is contstructed with
        %               in-memory data. (Optional)
        %
        obj.object_id_ = polyval(randi([0, 9], 1, 5), 10);
        if exist('mem_alloc', 'var')
            obj.validate_mem_alloc(mem_alloc);
            obj.page_memory_size_ = mem_alloc;
        else
            obj.page_memory_size_ = get(hor_config, 'pixel_page_size');
        end

        if nargin == 0
            return
        end
        % In memory construction
        if isa(arg, 'PixelData')  % TODO make sure this works with file-backed
            if arg.is_file_backed_() && exist(arg.file_path, 'file')
                % if the file exists we can create a file-backed instance
                obj = PixelData(arg.file_path, arg.page_memory_size_);
                obj.page_number_ = arg.page_number_;
                obj.page_dirty_ = arg.page_dirty_;
                obj.dirty_page_edited_ = arg.dirty_page_edited_;
                arg.tmp_io_handler_.copy_folder(obj.object_id_);
            else
                obj.num_pixels_ = size(arg.data, 2);
            end
            obj.data_ = arg.data;
            obj.page_memory_size_ = arg.page_memory_size_;
            return;
        end

        if numel(arg) == 1 && isnumeric(arg) && floor(arg) == arg
            % input is an integer
            obj.data_ = zeros(obj.PIXEL_BLOCK_COLS_, arg);
            obj.num_pixels_ = arg;
            return;
        end

        % File-backed construction
        if ischar(arg)
            % input is a file path
            f_accessor = sqw_formats_factory.instance().get_loader(arg);
            obj = obj.init_from_file_accessor_(f_accessor);
            return;
        end
        if isa(arg, 'sqw_binfile_common')
            % input is a file accessor
            obj = obj.init_from_file_accessor_(arg);
            return;
        end

        % Input sets underlying data
        if exist('mem_alloc', 'var') && ...
                (obj.calculate_page_size_(mem_alloc) < size(arg, 2))
            error('PIXELDATA:PixelData', ...
                    ['The size of the input array cannot exceed the given ' ...
                    'memory_allocation.']);
        end
        obj.data_ = arg;
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

    function is_empty = isempty(obj)
        % Return true if the PixelData object holds no pixel data
        is_empty = obj.num_pixels == 0;
    end

    function s = size(obj, varargin)
        % Return the size of the PixelData
        %   Axis 1 gives the number of columns, axis 2 gives the number of
        %   pixels. Along with Matlab convention, any other axis returns 1.
        if nargin == 1
            s = [obj.PIXEL_BLOCK_COLS_, obj.num_pixels];
        else
            s = ones(1, numel(varargin));
            for i = 1:numel(varargin)
                dim = varargin{i};
                if dim == 1
                    s(i) = obj.PIXEL_BLOCK_COLS_;
                elseif dim == 2
                    s(i) = obj.num_pixels;
                else
                    s(i) = size(obj.data, dim);
                end
            end
        end
    end

    function nel = numel(obj)
        % Return the number of data points in the pixel data block
        %   If the data is file backed, this returns the number of values in
        %   the file.
        nel = obj.PIXEL_BLOCK_COLS_*obj.num_pixels;
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
    function data = get_data(obj, fields, pix_indices)
        % Retrive data for a field, or fields, for the given pixel indices in
        % the current page. If no pixel indices are given, all pixels in the
        % current page are returned.
        %
        % This method provides a convinient way of retrieving multiple fields
        % of data from the pixel block. When retrieving multiple fields, the
        % columns of data will be ordered corresponding to the order the fields
        % appear in the inputted cell array.
        %
        %   >> sig_and_err = pix.get_data({'signal', 'variance'})
        %        retrives the signal and variance over the whole range of pixels
        %
        %   >> run_det_id_range = pix.get_data({'run_idx', 'detector_idx'}, 4:10);
        %        retrives the run and detector IDs for pixels 4 to 10
        %
        % Input:
        % ------
        %   fields      The name of a field, or a cell array of field names
        %   pix_indices The pixel indices to retrieve, if not given, get full range
        %
        if ~isa(fields, 'cell')
            fields = {fields};
        end
        obj = obj.load_current_page_if_data_empty_();
        try
            field_indices = cell2mat(obj.FIELD_INDEX_MAP_.values(fields));
        catch ME
            switch ME.identifier
            case 'MATLAB:Containers:Map:NoKey'
                error('PIXELDATA:get_data', ...
                      'Invalid field requested in PixelData.get_data().')
            otherwise
                rethrow(ME)
            end
        end

        if nargin < 3
            % No pixel indices given, return them all
            data = obj.data(field_indices, :);
        else
            data = obj.data(field_indices, pix_indices);
        end
    end

    function pixels = get_pixels(obj, pix_indices)
        % Retrieve the pixels at the given indices in the current page, return
        % a new PixelData object
        %
        % Input:
        % ------
        %   pix_indices     1-D array of pixel indices to retrieve
        %
        % Output:
        % -------
        %   pixels      PixelData object containing a subset of pixels
        %
        obj = obj.load_current_page_if_data_empty_();
        pixels = PixelData(obj.data(:, pix_indices));
    end

    function has_more = has_more(obj)
        % Returns true if there are subsequent pixels stored in the file that
        % are not held in the current page
        %
        %    >> has_more = pix.has_more();
        %
        has_more = false;
        if ~obj.is_file_backed_()
            return;
        end
        if obj.page_size == 0 && obj.num_pixels > obj.max_page_size_
            % If nothing has been loaded into the cache yet (page_size == 0),
            % the object acts as though the first page has been loaded. So
            % return true if there's more than one page worth of pixels
            has_more = true;
        else
            has_more = obj.pix_position_ + obj.max_page_size_  <= obj.num_pixels;
        end
    end

    function obj = advance(obj)
        % Load the next page of pixel data from the file backing the object
        %
        % This function will throw a PIXELDATA:advance error if attempting to
        % advance past the final page of data in the file.
        %
        % This function does nothing if the pixel data is not file-backed.
        %
        if obj.is_file_backed_()
            if obj.page_is_dirty_(obj.page_number_) && obj.dirty_page_edited_
                obj.write_dirty_page_();
            end
            try
                obj.load_page_(obj.page_number_ + 1);
            catch ME
                switch ME.identifier
                case 'PIXELDATA:load_page_'
                    error('PIXELDATA:advance', ...
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
        if obj.is_file_backed_() && obj.page_number_ ~= 1
            if obj.page_is_dirty_(obj.page_number_) && obj.dirty_page_edited_
                obj.write_dirty_page_();
            end
            obj.page_number_ = 1;
            obj.dirty_page_edited_ = false;
            obj.data_ = zeros(obj.PIXEL_BLOCK_COLS_, 0);
        end
    end

    % --- Getters / Setters ---
    function pixel_data = get.data(obj)
        obj = obj.load_current_page_if_data_empty_();
        pixel_data = obj.data_;
    end

    function obj = set.data(obj, pixel_data)
        % This setter provides rules for public facing edits to the cached data
        if obj.page_size == 0
            % no pixels loaded, get our expected page size
            required_page_size = min(obj.max_page_size_, obj.num_pixels);
        else
            required_page_size = obj.page_size;
        end

        if size(pixel_data, 2) ~= required_page_size
            msg = ['Cannot set pixel data, invalid dimensions. Axis 2 ' ...
                   'must have num elements matching current page size (%i), ' ...
                   'found ''%i''.'];
            error('PIXELDATA:data', msg, required_page_size, size(pixel_data, 2));
        end
        obj.data_ = pixel_data;
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
            error('PIXELDATA:data', msg, obj.PIXEL_BLOCK_COLS_, ...
                  size(pixel_data, 1));
        elseif ~isnumeric(pixel_data)
            msg = ['Cannot set pixel data, invalid type. Data must have a '...
                   'numeric type, found ''%s''.'];
            error('PIXELDATA:data', msg, class(pixel_data));
        end
        obj.raw_data_ = pixel_data;
    end

    function u1 = get.u1(obj)
        obj = obj.load_current_page_if_data_empty_();
        u1 = obj.data(obj.FIELD_INDEX_MAP_('u1'), :);
    end

    function obj = set.u1(obj, u1)
        obj = obj.load_current_page_if_data_empty_();
        obj.data(obj.FIELD_INDEX_MAP_('u1'), :) = u1;
        obj.set_page_dirty_(true);
    end

    function u2 = get.u2(obj)
        obj = obj.load_current_page_if_data_empty_();
        u2 = obj.data(obj.FIELD_INDEX_MAP_('u2'), :);
    end

    function obj = set.u2(obj, u2)
        obj = obj.load_current_page_if_data_empty_();
        obj.data(obj.FIELD_INDEX_MAP_('u2'), :) = u2;
        obj.set_page_dirty_(true);
    end

    function u3 = get.u3(obj)
        obj = obj.load_current_page_if_data_empty_();
        u3 = obj.data(obj.FIELD_INDEX_MAP_('u3'), :);
    end

    function obj = set.u3(obj, u3)
        obj = obj.load_current_page_if_data_empty_();
        obj.data(obj.FIELD_INDEX_MAP_('u3'), :) = u3;
        obj.set_page_dirty_(true);
    end

    function dE = get.dE(obj)
        obj = obj.load_current_page_if_data_empty_();
        dE = obj.data(obj.FIELD_INDEX_MAP_('dE'), :);
    end

    function obj = set.dE(obj, dE)
        obj = obj.load_current_page_if_data_empty_();
        obj.data(obj.FIELD_INDEX_MAP_('dE'), :) = dE;
        obj.set_page_dirty_(true);
    end

    function coord_data = get.coordinates(obj)
        obj = obj.load_current_page_if_data_empty_();
        coord_data = obj.data(obj.FIELD_INDEX_MAP_('coordinates'), :);
    end

    function obj = set.coordinates(obj, coordinates)
        obj = obj.load_current_page_if_data_empty_();
        obj.data(obj.FIELD_INDEX_MAP_('coordinates'), :) = coordinates;
        obj.set_page_dirty_(true);
    end

    function coord_data = get.q_coordinates(obj)
        obj = obj.load_current_page_if_data_empty_();
        coord_data = obj.data(obj.FIELD_INDEX_MAP_('q_coordinates'), :);
    end

    function obj = set.q_coordinates(obj, q_coordinates)
        obj = obj.load_current_page_if_data_empty_();
        obj.data(obj.FIELD_INDEX_MAP_('q_coordinates'), :) = q_coordinates;
        obj.set_page_dirty_(true);
    end

    function run_index = get.run_idx(obj)
        obj = obj.load_current_page_if_data_empty_();
        run_index = obj.data(obj.FIELD_INDEX_MAP_('run_idx'), :);
    end

    function obj = set.run_idx(obj, iruns)
        obj = obj.load_current_page_if_data_empty_();
        obj.data(obj.FIELD_INDEX_MAP_('run_idx'), :) = iruns;
        obj.set_page_dirty_(true);
    end

    function detector_index = get.detector_idx(obj)
        obj = obj.load_current_page_if_data_empty_();
        detector_index = obj.data(obj.FIELD_INDEX_MAP_('detector_idx'), :);
    end

    function obj = set.detector_idx(obj, detector_indices)
        obj = obj.load_current_page_if_data_empty_();
        obj.data(obj.FIELD_INDEX_MAP_('detector_idx'), :) = detector_indices;
        obj.set_page_dirty_(true);
    end

    function detector_index = get.energy_idx(obj)
        obj = obj.load_current_page_if_data_empty_();
        detector_index = obj.data(obj.FIELD_INDEX_MAP_('energy_idx'), :);
    end

    function obj = set.energy_idx(obj, energies)
        obj = obj.load_current_page_if_data_empty_();
        obj.data(obj.FIELD_INDEX_MAP_('energy_idx'), :) = energies;
        obj.set_page_dirty_(true);
    end

    function signal = get.signal(obj)
        obj = obj.load_current_page_if_data_empty_();
        signal = obj.data(obj.FIELD_INDEX_MAP_('signal'), :);
    end

    function obj = set.signal(obj, signal)
        obj = obj.load_current_page_if_data_empty_();
        obj.data(obj.FIELD_INDEX_MAP_('signal'), :) = signal;
        obj.set_page_dirty_(true);
    end

    function variance = get.variance(obj)
        obj = obj.load_current_page_if_data_empty_();
        variance = obj.data(obj.FIELD_INDEX_MAP_('variance'), :);
    end

    function obj = set.variance(obj, variance)
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
            page_size = min(obj.get_max_page_size_(), obj.num_pixels);
        else
            page_size = size(obj.data_, 2);
        end
    end

    function pix_position = get.pix_position_(obj)
        pix_position = (obj.page_number_ - 1)*obj.max_page_size_ + 1;
    end

    function page_size = get.max_page_size_(obj)
        page_size = obj.get_max_page_size_();
    end

end

methods (Access=private)

    function obj = init_from_file_accessor_(obj, f_accessor)
        % Initialise a PixelData object from a file accessor
        obj.f_accessor_ = f_accessor;
        obj.file_path_ = fullfile(obj.f_accessor_.filepath, ...
                                  obj.f_accessor_.filename);
        obj.tmp_io_handler_ = PixelTmpFileHandler(obj.object_id_);
        obj.page_number_ = 1;
        obj.num_pixels_ = double(obj.f_accessor_.npixels);
    end

    function obj = load_current_page_if_data_empty_(obj)
        % Check if there's any data in the current page and load a page if not
        %   This function does nothing if pixels are not file-backed.
        if obj.cache_is_empty_() && obj.is_file_backed_()
            obj = obj.load_page_(obj.page_number_);
        end
    end

    function obj = load_page_(obj, page_number)
        % Load the data for the given page index
        if obj.page_is_dirty_(page_number)
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
        pix_idx_start = (page_number - 1)*obj.max_page_size_ + 1;
        if pix_idx_start > obj.num_pixels
            error('PIXELDATA:load_page_', ...
                  'pix_idx_start exceeds number of pixels in file. %i >= %i', ...
                  pix_idx_start, obj.num_pixels);
        end
        % Get the index of the final pixel to read given the maximum page size
        pix_idx_end = min(pix_idx_start + obj.max_page_size_ - 1, obj.num_pixels);

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
        obj.tmp_io_handler_.write_page(obj.page_number_, obj.data);
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

    function page_size = get_max_page_size_(obj)
        % Get the maximum number of pixels that can be held in a page that's
        % allocated 'obj.page_memory_size_' bytes of memory
        page_size = obj.calculate_page_size_(obj.page_memory_size_);
    end

    function page_size = calculate_page_size_(obj, mem_alloc)
        % Calculate number of pixels that fit in the given memory allocation
        num_bytes_in_pixel = obj.DATA_POINT_SIZE*obj.PIXEL_BLOCK_COLS_;
        page_size = floor(mem_alloc/num_bytes_in_pixel);
    end

    function is = is_file_backed_(obj)
        % Return true if the pixel data is backed by a file or files. Returns
        % false if all pixel data is held in memory
        %
        is = ~isempty(obj.f_accessor_) || obj.get_num_pages_() > 1;
    end

    function is = cache_is_empty_(obj)
        % Return true if no pixels are currently held in memory
        is = isempty(obj.data_);
    end

    function num_pages = get_num_pages_(obj)
        num_pages = max(ceil(obj.num_pixels/obj.max_page_size_), 1);
    end

end

end
