classdef PixelDataMemory < PixelDataBase
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


    properties (Constant)
        is_filebacked = false;
    end

    methods
        % --- Pixel operations ---
        pix_out = append(obj, pix);
        [mean_signal, mean_variance] = compute_bin_data(obj, npix);
        pix_out = do_binary_op(obj, operand, binary_op, varargin);
        pix_out = do_unary_op(obj, unary_op);
        [ok, mess] = equal_to_tol(obj, other_pix, varargin);
        pix_out = get_data(obj, fields, abs_pix_indices);
        pix_out = get_pix_in_ranges(obj, abs_indices_starts, block_sizes,...
            recalculate_pix_ranges,keep_precision);
        pix_out = get_pixels(obj, abs_pix_indices);
        pix_out = mask(obj, mask_array, npix);
        [page_num, total_number_of_pages] = move_to_page(obj, page_number, varargin);
        pix_out = noisify(obj, varargin);
        obj = recalc_pix_range(obj);
        set_data(obj, fields, data, abs_pix_indices);

        function obj = PixelData(arg, mem_alloc,upgrade)
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
            %>> obj = PixelData(__,false) -- not upgrade class averages
            %         (pix_range) for old file format, if these averages
            %         are not stored in the file. Default -- true. Pixel
            %         averages are calculated on construction
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

            obj = PixelData(arg, mem_alloc,upgrade);
        end

        function data=saveobj(obj)
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
        end

        % --- Getters / Setters ---
        function pixel_data = get.data(obj)
            pixel_data = obj.data_;
        end

        function set.data(obj, pixel_data)
            % This setter provides rules for public facing edits to the cached data
            obj.data_ = pixel_data;
            obj.reset_changed_coord_range('coordinates');
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
            u1 = obj.data(obj.FIELD_INDEX_MAP_('u1'), :);
        end

        function set.u1(obj, u1)
            obj.data(obj.FIELD_INDEX_MAP_('u1'), :) = u1;
            obj.reset_changed_coord_range('u1');
        end

        function u2 = get.u2(obj)
            u2 = obj.data(obj.FIELD_INDEX_MAP_('u2'), :);
        end

        function set.u2(obj, u2)
            obj.data(obj.FIELD_INDEX_MAP_('u2'), :) = u2;
            obj.reset_changed_coord_range('u2');
        end

        function u3 = get.u3(obj)
            u3 = obj.data(obj.FIELD_INDEX_MAP_('u3'), :);
        end

        function set.u3(obj, u3)
            obj.data(obj.FIELD_INDEX_MAP_('u3'), :) = u3;
            obj.reset_changed_coord_range('u3');
        end

        function dE = get.dE(obj)
            dE = obj.data(obj.FIELD_INDEX_MAP_('dE'), :);
        end

        function set.dE(obj, dE)
            obj.data(obj.FIELD_INDEX_MAP_('dE'), :) = dE;
            obj.reset_changed_coord_range('dE');
        end

        function coord_data = get.coordinates(obj)
            coord_data = obj.data(obj.FIELD_INDEX_MAP_('coordinates'), :);
        end

        function set.coordinates(obj, coordinates)
            obj.data(obj.FIELD_INDEX_MAP_('coordinates'), :) = coordinates;
            obj.reset_changed_coord_range('coordinates');
        end

        function coord_data = get.q_coordinates(obj)
            coord_data = obj.data(obj.FIELD_INDEX_MAP_('q_coordinates'), :);
        end

        function set.q_coordinates(obj, q_coordinates)
            obj.data(obj.FIELD_INDEX_MAP_('q_coordinates'), :) = q_coordinates;
            obj.reset_changed_coord_range('q_coordinates');
        end

        function run_index = get.run_idx(obj)
            run_index = obj.data(obj.FIELD_INDEX_MAP_('run_idx'), :);
        end

        function set.run_idx(obj, iruns)
            obj.data(obj.FIELD_INDEX_MAP_('run_idx'), :) = iruns;
        end

        function detector_index = get.detector_idx(obj)
            detector_index = obj.data(obj.FIELD_INDEX_MAP_('detector_idx'), :);
        end

        function set.detector_idx(obj, detector_indices)
            obj.data(obj.FIELD_INDEX_MAP_('detector_idx'), :) = detector_indices;
        end

        function detector_index = get.energy_idx(obj)
            detector_index = obj.data(obj.FIELD_INDEX_MAP_('energy_idx'), :);
        end

        function set.energy_idx(obj, energies)
            obj.data(obj.FIELD_INDEX_MAP_('energy_idx'), :) = energies;
        end

        function signal = get.signal(obj)
            signal = obj.data(obj.FIELD_INDEX_MAP_('signal'), :);
        end

        function set.signal(obj, signal)
            obj.data(obj.FIELD_INDEX_MAP_('signal'), :) = signal;
        end

        function variance = get.variance(obj)
            variance = obj.data(obj.FIELD_INDEX_MAP_('variance'), :);
        end

        function set.variance(obj, variance)
            obj.data(obj.FIELD_INDEX_MAP_('variance'), :) = variance;
        end

        function num_pix = get.num_pixels(obj)
            num_pix = obj.num_pixels_;
        end

        function file_path = get.file_path(obj)
            file_path = obj.file_path_;
        end

        function set.file_path(obj,val)
            if ~(ischar(val)||isstring(val))
                error('HORACE:PixelData:invalid_argument',...
                      'filename for PixelData have to be char string');
            end
            obj.file_path_ = val;
        end

        function page_size = get.page_size(obj)
            % The number of pixels that are held in the current page.
            page_size = obj.num_pixels;
        end

        function pix_position = get.pix_position_(obj)
            pix_position = 1;
        end

        function page_size = get.base_page_size(obj)
            page_size = calculate_page_size_(obj,obj.page_memory_size_);
        end

        function range = get.pix_range(obj)
            range  = obj.pix_range_;
        end

        function set_range(obj,pix_range)
            % Function allows to set the pixels range (min/max values of
            % pixels coordinates)
            %
            % Use with caution!!! As this is performance function,
            % no checks that the set range is the
            % correct range for pixels, holded by the class are
            % performed, while subsequent algorithms may rely on pix range
            % to be correct. A out-of memory assignment can occur during
            % rebinning if the range is smaller, then the actual range.
            %
            % Necessary to set up the pixel range when filebased
            % pixels are modified by algorithm and correct range
            % calculations are expensive
            %
            if any(size(pix_range) ~= [2,4])
                error('HORACE:PixelData:InvalidArgument',...
                    'pixel_range should be [2x4] array');
            end
            obj.pix_range_ = pix_range;
        end

        function np = get.n_pages(obj)
            np = 1;
        end

    end

    methods (Access=private)

        function reset_changed_coord_range(obj,field_name)
            % Recalculate and set appropriate range of pixel coordinates.
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

            range = [min(obj.raw_data_(ind,:),[],2),max(obj.raw_data_(ind,:),[],2)]';
            obj.pix_range_(:,ind) = range;
            obj.page_range(:,ind) = range;
        end
    end

end
