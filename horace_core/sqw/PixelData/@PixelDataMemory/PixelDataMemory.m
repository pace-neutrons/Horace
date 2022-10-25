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
    %   >> pix_data = PixelDataBase.create(data);
    %   >> pix_data = PixelDataBase.create('/path/to/sqw.sqw');
    %   >> pix_data = PixelDataBase.create('/path/to/sqw.sqw', mem_alloc);
    %   >> pix_data = PixelDataBase.create(faccess_obj);
    %   >> pix_data = PixelDataBase.create(faccess_obj, mem_alloc);
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
    %   >> pix_data = PixelDataBase.create(data)
    %   >> signal = pix_data.signal;
    %
    %  or equivalently:
    %
    %   >> pix_data = PixelDataBase.create();
    %   >> pix_data.data = data;
    %   >> signal = pix_data.get_data('signal');
    %
    %  To retrieve multiple fields of data, e.g. run_idx and energy_idx, for pixels 1 to 10:
    %
    %   >> pix_data = PixelDataBase.create(data);
    %   >> signal = pix_data.get_data({'run_idx', 'energy_idx'}, 1:10);
    %
    %  To retrieve data for pixels 1, 4 and 10 (returning another PixelData object):
    %
    %   >> pix_data = PixelDataBase.create(data);
    %   >> pixel_subset = pix_data.get_pixels([1, 4, 10])
    %
    %  To sum the signal of a file-backed object where the page size is less than
    %  amount of data in the file:
    %
    %   >> pix = PixelDataBase.create('my_data.sqw')
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

    properties
        page_memory_size_ = inf;
        file_path_ = '';
    end

    properties (Constant)
        is_filebacked = false;
        n_pages = 1;
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
        pix_out = noisify(obj, varargin);
        obj = recalc_pix_range(obj);
        set_data(obj, fields, data, abs_pix_indices);

        function obj = PixelDataMemory(init, mem_alloc, upgrade)
            % Construct a PixelDataMemory object from the given data. Default
            % construction initialises the underlying data as an empty (9 x 0)
            % array.
            %
            % Transform filebacked to memory backed

            obj.object_id_ = randi([10, 99999], 1, 1);
            if exist('init', 'var')
                if isstruct(init)
                    obj = obj.loadobj(init);
                elseif ischar(init) || isstring(init)
                    if ~is_file(init)
                        error('HORACE:PixelDataFileBacked:invalid_argument', ...
                              'Cannot find file to load (%s)', init)
                    end

                    init = sqw_formats_factory.instance().get_loader(init);
                    obj = obj.init_from_file_accessor_(init);

                elseif isa(init, 'sqw_file_interface')
                    obj = obj.init_from_file_accessor_(init);

                elseif isa(init, 'PixelDataMemory')
                    obj.num_pixels_ = size(init.data, 2);
                    obj.data_ = init.data;
                    obj.reset_changed_coord_range('coordinates')

                elseif isscalar(init) && isnumeric(init) && floor(init) == init
                    % input is an integer
                    obj.data_ = zeros(obj.PIXEL_BLOCK_COLS_, init);
                    obj.num_pixels_ = init;
                    obj.pix_range_ = zeros(2,4);

                elseif isnumeric(init)
                    obj.data_ = init;
                    obj.num_pixels_ = size(init, 2);
                    obj.reset_changed_coord_range('coordinates')

                elseif isa(init, 'PixelDataFileBacked')
                    init.move_to_first_page();
                    obj.data_ = init.data;
                    while init.has_more()
                        init.advance();
                        obj.data_ = horzcat(obj.data, init.data);
                    end

                    obj.reset_changed_coord_range('coordinates');
                    obj.num_pixels_ = obj.num_pixels;
                else
                    error('HORACE:PixelDataMemory:invalid_argument', ...
                          'Cannot construct PixelDataMemory from class (%s)', class(init))
                end
            end

        end


        function data=saveobj(obj)
            data = struct(obj);

            if numel(obj)>1
                data = struct('version',PixelDataBase.version,...
                    'array_data',data);
            else
                data.version = obj.version;
            end
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

        function empty = cache_is_empty_(obj)
            % Returns true if there are subsequent pixels stored in the file that
            % are not held in the current page
            %
            %    >> has_more = pix.has_more();
            %
            empty = false;
        end

        function [page_number,total_num_pages] = move_to_page(obj, page_number, varargin)
            % Set the object to point at the given page number
            %   This function does nothing if the object is not file-backed or is
            %   already on the given page
            %
            % Inputs:
            % page_number -- page number to move to
            %
            % Returns:
            % page_number -- the page this routine moved to
            % total_num_pages -- total number of pages, present in the file
            %
            total_num_pages = 1;
            if page_number ~= 1
                error('HORACE:PIXELDATA:move_to_page', ...
                      'Cannot advance to page %i only %i pages of data found.', ...
                      page_number, 1);
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
        end

        % --- Getters / Setters ---
        function data = get_raw_data(obj)
            data = obj.raw_data_;
        end

        function set_raw_data(obj, pixel_data)
            % This setter provides rules for internally setting cached data
            %  This is the only method that should ever touch obj.raw_data_

            % The need for multiple layers of getters/setters for the raw data
            % should be removed when the public facing getters/setters are removed.
            validateattributes(pixel_data, {'numeric'}, {'nrows', obj.PIXEL_BLOCK_COLS_})
            obj.raw_data_ = pixel_data;
            obj.num_pixels_ = size(pixel_data,2); % breaks filebased
        end

        function prp = get_prop(obj, fld)
            prp = obj.data_(obj.FIELD_INDEX_MAP_(fld), :);
        end

        function set_prop(obj, fld, val)
            obj.data_(obj.FIELD_INDEX_MAP_(fld), :) = val;
            if ismember(fld, ["u1", "u2", "u3", "dE", "q_coordinates", "coordinates", "all"])
                obj.reset_changed_coord_range(fld);
            end
        end

    end

    methods (Access = ?PixelDataBase)
        function obj = init_from_file_accessor_(obj, f_accessor)
        % Initialise a PixelData object from a file accessor
            obj.num_pixels_ = double(f_accessor.npixels);
            obj.pix_range_ = f_accessor.get_pix_range();
            obj.data_ = f_accessor.get_raw_pix();

        end

        function reset_changed_coord_range(obj,field_name)
            % Recalculate and set appropriate range of pixel coordinates.
            % The coordinates are defined by the selected field
            %
            % Sets up the property page_range defining the range of block
            % of pixels chaned at current iteration.
            %
            if isempty(obj.raw_data_)
                obj.pix_range_   = PixelDataBase.EMPTY_RANGE_;
                return
            end

            if field_name == "all"
                field_name = "coordinates"
            end

            ind = obj.FIELD_INDEX_MAP_(field_name);

            range = [min(obj.raw_data_(ind,:),[],2),max(obj.raw_data_(ind,:),[],2)]';
            obj.pix_range_(:,ind) = range;
        end
    end

end
