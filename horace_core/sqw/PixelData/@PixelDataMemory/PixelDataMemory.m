classdef PixelDataMemory < PixelDataBase
    % PixelDataMemory Provides an interface for access to memory-backed pixel data
    %
    %   This class provides getters and setters for each data column in an SQW
    %   pixel array. You can access the data using the attributes listed below,
    %   using the get_data() method (to retrieve column data) or using the
    %   get_pixels() method (retrieve raw data).
    %
    %   Construct this class with an 9 x N array, a file path to an SQW object or
    %   an instance of sqw_binfile_common.
    %
    %   >> pix_data = PixelDataMemory(data);
    %   >> pix_data = PixelDataMemory('/path/to/sqw.sqw');
    %   >> pix_data = PixelDataMemory(faccess_obj);
    %
    % Usage:
    %
    %   >> pix_data = PixelDataMemory(data)
    %   >> signal = pix_data.signal;
    %
    %  or equivalently:
    %
    %   >> pix_data = PixelDataMemory();
    %   >> pix_data.data = data;
    %   >> signal = pix_data.get_fields('signal');
    %
    %  To retrieve multiple fields of data, e.g. run_idx and energy_idx, for pixels 1 to 10:
    %
    %   >> pix_data = PixelDataMemory(data);
    %   >> signal = pix_data.get_fields({'run_idx', 'energy_idx'}, 1:10);
    %
    %  To retrieve data for pixels 1, 4 and 10 (returning another PixelData object):
    %
    %   >> pix_data = PixelDataMemory(data);
    %   >> pixel_subset = pix_data.get_pixels([1, 4, 10])
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
    properties(Access=protected)
        data_ = zeros(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 0);  % the underlying data cached in the object
    end

    properties
        page_memory_size_ = inf;
    end

    properties(Constant)
        is_filebacked = false;
        n_pages = 1;
    end

    methods
        % --- Pixel operations ---
        pix_out = append(obj, pix);
        pix     = set_raw_data(obj,pix);
        obj     = set_raw_fields(obj, data, fields, abs_pix_indices);

        [mean_signal, mean_variance] = compute_bin_data(obj, npix);
        pix_out = do_binary_op(obj, operand, binary_op, varargin);
        pix_out = do_unary_op(obj, unary_op);
        [ok, mess] = equal_to_tol(obj, other_pix, varargin);

        pix_out = get_pixels(obj, abs_pix_indices,varargin);

        pix_out = mask(obj, mask_array, npix);
        pix_out = noisify(obj, varargin);

        pix_out = get_fields(obj, fields, abs_pix_indices);

    end

    methods
        function obj = PixelDataMemory(varargin)
            % Construct a PixelDataMemory object from the given data. Default
            % construction initialises the underlying data as an empty (9 x 0)
            % array.
            %
            if nargin == 0
                return
            end
            obj = obj.init(varargin{:});
        end

        function obj = init(obj,varargin)
            % Main part of PixelDataMemory constructor.
            obj = init_(obj,varargin{:});
        end

        function [obj,unique_pix_id] = recalc_data_range(obj)
            % Recalculate pixels range in the situations, where the
            % range for some reason appeared to be missing (i.e. loading pixels from
            % old style files) or changed through private interface (for efficiency)
            % and the internal integrity of the object has been violated.
            %
            % returns obj for compatibility with recalc_pix_range method of
            % combine_pixel_info class, which may be used instead of PixelData
            % for the same purpose.
            % recalc_pix_range is a normal Matlab value object (not a handle object),
            % returning its changes in LHS

            obj=obj.reset_changed_coord_range('all');
            if nargout == 2
                unique_pix_id = unique(obj.run_idx);
            end
        end

        function [page_number,total_num_pages] = move_to_page(~, page_number, varargin)
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

        function [pix_idx_start, pix_idx_end] = get_page_idx_(obj, varargin)
            pix_idx_start = 1;
            pix_idx_end   = obj.num_pixels;
        end

        function [obj,varargout]=reset_changed_coord_range(obj,field_name)
            % Recalculate and set appropriate range of pixel coordinates.
            % The coordinates are defined by the selected field
            %
            % Sets up the property page_range defining the range of block
            % of pixels changed at current iteration.

            if isempty(obj.data_)
                obj.data_range_   = PixelDataBase.EMPTY_RANGE;
                return
            end
            if iscell(field_name)
                ind = obj.check_pixel_fields(field_name);
            else
                ind = obj.FIELD_INDEX_MAP_(field_name);
            end

            obj.data_range_(:,ind) = obj.pix_minmax_ranges(obj.data(ind,:));
            if nargout>1
                varargout{1} = unique(obj.run_idx);
            end
        end
    end

    methods(Static)
        function obj = cat(varargin)
        % Concatenate the given PixelData objects' pixels. This function performs
        % a straight-forward data concatenation.
        %
        %   >> joined_pix = PixelDataMemory.cat(pix_data1, pix_data2);
        %
        % Input:
        % ------
        %   varargin    A cell array of PixelData objects
        %
        % Output:
        % -------
        %   obj         A PixelData object containing all the pixels in the inputted
        %               PixelData objects
            is_ldr = cellfun(@(x) isa(x, 'sqw_file_interface'), varargin);

            if any(is_ldr)
                obj = PixelDataFileBacked(varargin);
                return
            end

            obj = PixelDataMemory();
            for i = 1:numel(varargin)
                curr_pix = varargin{i};
                for page = 1:curr_pix.num_pages
                    [curr_pix,data] = curr_pix.load_page(page);
                    obj.data = [obj.data, data];
                end
            end
            obj = obj.recalc_data_range();
        end
    end

    methods(Static)
        function obj = cat(varargin)
        % Concatenate the given PixelData objects' pixels. This function performs
        % a straight-forward data concatenation.
        %
        %   >> joined_pix = PixelDataMemory.cat(pix_data1, pix_data2);
        %
        % Input:
        % ------
        %   varargin    A cell array of PixelData objects
        %
        % Output:
        % -------
        %   obj         A PixelData object containing all the pixels in the inputted
        %               PixelData objects
            is_ldr = cellfun(@(x) isa(x, 'sqw_file_interface'), varargin);

            if ~any(is_ldr)
                obj = PixelDataFilebacked(varargin);
                return
            end

            obj = PixelDataMemory();
            for i = 1:numel(varargin)
                curr_pix = varargin{i};
                for page = 1:curr_pix.num_pages
                    [curr_pix,data] = curr_pix.load_page(page);
                    obj = obj.append(data);
                end
            end
        end
    end

    methods(Access=protected)

        function np = get_page_num(~)
            np = 1;
        end

        function obj = set_page_num(obj,varargin)
            % do nothing. Only 1 is pagenum in pixel_data
        end

        function  page_size = get_page_size(obj)
            page_size = size(obj.data_,2);
        end

        function np = get_num_pages(~)
            np = 1;
        end

        function data =  get_raw_data(obj)
            % main part of get.data accessor
            data = obj.data_;
        end

        function num_pix = get_num_pixels(obj)
            % num_pixels getter
            num_pix = size(obj.data_,2);
        end

        function obj=set_prop(obj, fld, val)
            val = check_set_prop(obj,fld,val);
            obj.data_(obj.FIELD_INDEX_MAP_(fld), :) = val;
            obj=obj.reset_changed_coord_range(fld);
        end

        function prp = get_prop(obj, fld)
            prp = obj.data_(obj.FIELD_INDEX_MAP_(fld), :);
        end

        function obj=set_data_wrap(obj,val)
            % main part of pix_data_wrap setter overloaded for
            % PixDataMemory class
            if ~isa(val,'pix_data')
                error('HORACE:PixelDataMemory:invalid_argument', ...
                    'pix_data_wrap property can be set by pix_data class instance only. Provided class is: %s', ...
                    class(val));
            end
            if ~isnumeric(val.data)
                error('HORACE:PixelDataMemory:invalid_argument', ...
                    'Attempt to initialize PixelDataMemory using pix_data values obtained from PixelDataFilebacked class: %s', ...
                    disp2str(val));
            end
            obj.data_ = val.data;
        end
    end

    %======================================================================
    % SERIALIZABLE INTERFACE
    methods(Static)
        function obj = loadobj(S,varargin)
            % loadobj method, calling generic method of
            % serializable class if modern instance of data is provided.
            % or calling parent class, to recalculate old data
            if isfield(S,'serial_name')
                obj = PixelDataMemory();
                obj = loadobj@serializable(S,obj);
            else
                obj = loadobj@PixelDataBase(S);
            end

        end
    end
end
