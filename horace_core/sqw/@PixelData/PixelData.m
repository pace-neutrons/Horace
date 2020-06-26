classdef PixelData < matlab.mixin.Copyable
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
    PIXEL_BLOCK_COLS_ = 9;
    FIELD_INDEX_MAP_ = containers.Map(...
        {'u1', 'u2', 'u3', 'dE', ...
         'coordinates', ...
         'q_coordinates', ...
         'run_idx', ...
         'detector_idx', ...
         'energy_idx', ...
         'signal', ...
         'variance'}, ...
        {1, 2, 3, 4, 1:4, 1:3, 5, 6, 7, 8, 9})

    data_ = zeros(9, 0);
    f_accessor_;  % instance of faccess object to access pixel data from file
    file_path_ = '';  % the path to the file backing this object - empty string if all data in memory
    page_memory_size_ = 3e9;  % 3Gb - the maximum amount of memory a page can use
    pix_position_ = 1;  % the pixel index in the file of the first pixel in the cache
    max_page_size_;  % the maximum number of pixels that can fie in the page memory size
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

    % The maximum number of pixels to be stored in memory at one time
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

        obj = PixelData(S);
    end

end

methods

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
        if nargin == 0
            return
        end
        % In memory construction
        if isa(arg, 'PixelData')  % TODO make sure this works with file-backed
            if ~isempty(arg.file_path) && exist(arg.file_path, 'file')
                % if the file exists we can create a file-backed instance
                obj = PixelData(arg.file_path, arg.page_memory_size_);
                obj.pix_position_ = arg.pix_position_;
            else
                % if no file exists, just copy the data
                obj.data = arg.data;
            end
            return;
        end
        if numel(arg) == 1 && isnumeric(arg) && floor(arg) == arg
            % input is an integer
            obj.data = zeros(obj.PIXEL_BLOCK_COLS_, arg);
            return;
        end

        % File-backed construction
        if nargin == 2
            obj.page_memory_size_ = mem_alloc;
        end
        obj.max_page_size_ = obj.get_max_page_size_(obj.page_memory_size_);
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
        obj.data = arg;
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
        %   the file
        nel = obj.PIXEL_BLOCK_COLS_*obj.num_pixels;
    end

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
        obj = obj.load_first_page_if_data_empty_();
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
        obj = obj.load_first_page_if_data_empty_();
        pixels = PixelData(obj.data(:, pix_indices));
    end

    function has_more = has_more(obj)
        % Returns true if there are subsequent pixels stored in the file that
        % are not held in the current page
        %
        %    >> has_more = pix.has_more();
        %
        has_more = false;
        if isempty(obj.f_accessor_)
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
        % advance past the final page of data in the file
        %
        if ~isempty(obj.f_accessor_)
            try
                obj.load_page_(obj.pix_position_ + obj.max_page_size_);
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

    % --- Getters / Setters ---
    function pixel_data = get.data(obj)
        obj = obj.load_first_page_if_data_empty_();
        pixel_data = obj.data_;
    end

    function obj = set.data(obj, pixel_data)
        if size(pixel_data, 1) ~= obj.PIXEL_BLOCK_COLS_
            msg = ['Cannot set pixel data, invalid dimensions. Axis 1 must '...
                   'have length %i, found ''%i''.'];
            error('PIXELDATA:data', msg, obj.PIXEL_BLOCK_COLS_, ...
                  size(pixel_data, 1));
        elseif ~isnumeric(pixel_data)
            msg = ['Cannot set pixel data, invalid type. Data must have a '...
                   'numeric type, found ''%i'''];
            error('PIXELDATA:data', msg, class(pixel_data));
        end
        obj.data_ = pixel_data;
    end

    function u1 = get.u1(obj)
        obj = obj.load_first_page_if_data_empty_();
        u1 = obj.data(obj.FIELD_INDEX_MAP_('u1'), :);
    end

    function obj = set.u1(obj, u1)
        obj.data(obj.FIELD_INDEX_MAP_('u1'), :) = u1;
    end

    function u2 = get.u2(obj)
        obj = obj.load_first_page_if_data_empty_();
        u2 = obj.data(obj.FIELD_INDEX_MAP_('u2'), :);
    end

    function obj = set.u2(obj, u2)
        obj.data(obj.FIELD_INDEX_MAP_('u2'), :) = u2;
    end

    function u3 = get.u3(obj)
        obj = obj.load_first_page_if_data_empty_();
        u3 = obj.data(obj.FIELD_INDEX_MAP_('u3'), :);
    end

    function obj = set.u3(obj, u3)
        obj.data(obj.FIELD_INDEX_MAP_('u3'), :) = u3;
    end

    function dE = get.dE(obj)
        obj = obj.load_first_page_if_data_empty_();
        dE = obj.data(obj.FIELD_INDEX_MAP_('dE'), :);
    end

    function obj = set.dE(obj, dE)
        obj.data(obj.FIELD_INDEX_MAP_('dE'), :) = dE;
    end

    function coord_data = get.coordinates(obj)
        obj = obj.load_first_page_if_data_empty_();
        coord_data = obj.data(obj.FIELD_INDEX_MAP_('coordinates'), :);
    end

    function obj = set.coordinates(obj, coordinates)
        obj.data(obj.FIELD_INDEX_MAP_('coordinates'), :) = coordinates;
    end

    function coord_data = get.q_coordinates(obj)
        obj = obj.load_first_page_if_data_empty_();
        coord_data = obj.data(obj.FIELD_INDEX_MAP_('q_coordinates'), :);
    end

    function obj = set.q_coordinates(obj, q_coordinates)
        obj.data(obj.FIELD_INDEX_MAP_('q_coordinates'), :) = q_coordinates;
    end

    function run_index = get.run_idx(obj)
        obj = obj.load_first_page_if_data_empty_();
        run_index = obj.data(obj.FIELD_INDEX_MAP_('run_idx'), :);
    end

    function obj = set.run_idx(obj, iruns)
        obj.data(obj.FIELD_INDEX_MAP_('run_idx'), :) = iruns;
    end

    function detector_index = get.detector_idx(obj)
        obj = obj.load_first_page_if_data_empty_();
        detector_index = obj.data(obj.FIELD_INDEX_MAP_('detector_idx'), :);
    end

    function obj = set.detector_idx(obj, detector_indices)
        obj.data(obj.FIELD_INDEX_MAP_('detector_idx'), :) = detector_indices;
    end

    function detector_index = get.energy_idx(obj)
        obj = obj.load_first_page_if_data_empty_();
        detector_index = obj.data(obj.FIELD_INDEX_MAP_('energy_idx'), :);
    end

    function obj = set.energy_idx(obj, energies)
        obj.data(obj.FIELD_INDEX_MAP_('energy_idx'), :) = energies;
    end

    function signal = get.signal(obj)
        obj = obj.load_first_page_if_data_empty_();
        signal = obj.data(obj.FIELD_INDEX_MAP_('signal'), :);
    end

    function obj = set.signal(obj, signal)
        obj.data(obj.FIELD_INDEX_MAP_('signal'), :) = signal;
    end

    function variance = get.variance(obj)
        obj = obj.load_first_page_if_data_empty_();
        variance = obj.data(obj.FIELD_INDEX_MAP_('variance'), :);
    end

    function obj = set.variance(obj, variance)
        obj.data(obj.FIELD_INDEX_MAP_('variance'), :) = variance;
    end

    function num_pix = get.num_pixels(obj)
        if isempty(obj.f_accessor_)
            num_pix = size(obj.data, 2);
        else
            num_pix = obj.f_accessor_.npixels;
        end
    end

    function file_path = get.file_path(obj)
        file_path = obj.file_path_;
    end

    function page_size = get.page_size(obj)
        % The number of pixels that are held in the current page.
        page_size = size(obj.data_, 2);
    end

end

methods (Access = private)

    function obj = init_from_file_accessor_(obj, f_accessor)
        % Initialise a PixelData object from a file accessor
        obj.f_accessor_ = f_accessor;
        obj.file_path_ = fullfile(obj.f_accessor_.filepath, ...
                                  obj.f_accessor_.filename);
    end

    function obj = load_page_(obj, pix_idx_start)
        % Load a page of data from the file starting at the given index
        if pix_idx_start >= obj.num_pixels
            error('PIXELDATA:load_page_', ...
                  'pix_idx_start exceeds number of pixels in file. %i >= %i', ...
                  pix_idx_start, obj.num_pixels);
        end
        % Get the index of the final pixel to read given the maximum page size
        pix_idx_end = pix_idx_start + obj.max_page_size_ - 1;
        if pix_idx_end > obj.num_pixels
            pix_idx_end = obj.num_pixels;
        end

        obj.data = obj.f_accessor_.get_pix(pix_idx_start, pix_idx_end);
        if obj.page_size == obj.num_pixels && obj.f_accessor_.is_activated()
            % Close the file if all pixels have been read
            obj.f_accessor_.deactivate();
        end
        obj.pix_position_ = pix_idx_start;
    end

    function obj = load_first_page_if_data_empty_(obj)
        % Check if there's any data in the current page and load a page if not
        if isempty(obj.data_) && ~isempty(obj.f_accessor_)
            obj = obj.load_page_(1);
        end
    end

    function page_size = get_max_page_size_(obj, mem_alloc)
        % Get the maximum number of pixels that can be held in a page that's
        % allocated 'mem_alloc' bytes
        num_bytes_in_val = 8;  % pixel data stored in memory as a double
        num_bytes_in_pixel = num_bytes_in_val*obj.PIXEL_BLOCK_COLS_;
        page_size = floor(mem_alloc/num_bytes_in_pixel);
    end

end

end
