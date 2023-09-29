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
    %   q_coordinates  - The spatial coords in projection axes of the pixel data [u1, u2, u3] (3 x n array)
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

    properties(Constant)
        is_filebacked = false;
        n_pages = 1;
    end
    %======================================================================
    % Implementing abstract PixelDataBase interface
    methods
        pix_out     = append(obj, pix);
        % apply function represented by handle to every pixel of the dataset
        % and calculate appropriate averages if requested
        [obj, data] = apply(obj, func_handle, args, data, compute_variance);
        [obj, sqw_out] = apply_c(obj, sqw_in,page_op);
        %
        function data =  get_raw_data(obj,varargin)
            % main part of get.data accessor
            data = obj.data_;
            if nargin>1
                idx = obj.field_index(varargin{1});
                data = data(idx,:);

            end
        end
        pix     = set_raw_data(obj,pix);

        pix_out = do_binary_op(obj, operand, binary_op, varargin);
        [pix_out, data] = do_unary_op(obj, unary_op, data);

        pix_out = mask(obj, mask_array, npix);

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
        function [obj,unique_pix_id] = recalc_data_range(obj,fld)
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
            if nargin == 1
                fld = 'all';
            end
            if nargout == 2
                [obj,unique_pix_id]=obj.calc_page_range(fld);
            else
                obj=obj.calc_page_range(fld);
            end
        end
    end
    %======================================================================
    % File handling/migration. Does nothing on membased
    methods
        function obj = prepare_dump(obj)
        end
        function obj = get_new_handle(obj, varargin)
        end
        function obj = format_dump_data(obj,varargin)
        end
        function obj = finish_dump(obj)
        end
        %
        function [pix_idx_start, pix_idx_end] = get_page_idx_(obj, varargin)
            pix_idx_start = 1;
            pix_idx_end   = obj.num_pixels;
        end

        function obj = move_to_first_page(obj)
            % Reset the object to point to the first page of pixel data in the file
            % and clear the current cache
            %  This function does nothing for memory backed pixels as there
            %  is only none page
            %
        end
    end

    methods
        function obj = tag(obj, selected)
            % Function to tag pixels to avoid e.g. duplicating pixels on
            % cut. Returned pixels have negative sign on detector index. When
            % operation is complete caller should discard pixels or use `untag`
            % function (below).
            %
            % Input
            % ------
            %   selected     indices of pixels to be tagged
            if ~exist('selected', 'var')
                obj.detector_idx = -obj.detector_idx;
            else
                obj.detector_idx(selected) = -obj.detector_idx(selected);
            end
        end

        function obj = untag(obj, selected)
            % Function to untag pixels when operation finished.
            %
            % Should generally be called without `selected` specified to
            % untag all pixels.
            %
            % Input
            % ------
            %   selected     indices of pixels to be untagged
            if ~exist('selected', 'var')
                obj.detector_idx = abs(obj.detector_idx);
            else
                obj.detector_idx(selected) = abs(obj.detector_idx(selected));
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

            if isempty(varargin)
                obj = PixelDataMemory();
                return;
            elseif numel(varargin) == 1
                if isa(varargin{1}, 'PixelDataFileBacked')
                    obj = PixelDataMemory(varargin{1});
                elseif isa(varargin{1}, 'PixelDataMemory')
                    obj = varargin{1};
                end
                return;
            end

            is_ldr = cellfun(@(x) isa(x, 'sqw_file_interface'), varargin);
            if any(is_ldr)
                obj = PixelDataFileBacked(varargin);
                return
            end

            obj = PixelDataMemory();

            obj.data_range_ = PixelDataBase.EMPTY_RANGE;
            for i = 1:numel(varargin)
                curr_pix = varargin{i};
                for page = 1:curr_pix.num_pages
                    curr_pix.page_num = page;
                    data = curr_pix.data;
                    obj.data_range = ...
                        obj.pix_minmax_ranges(data, obj.data_range_);
                    obj.data = [obj.data, data];
                end
            end
        end
    end
    %======================================================================
    % implementation of PixelDataBase abstract protected interface
    methods(Access=protected)
        function pix_data = get_raw_pix_data(obj,row_pix_idx,col_pix_idx)
            % return unmodified pixel data according to the input indexes
            % provided
            % Inputs:
            % obj         -- initialized pixel data memory object
            % row_pix_idx -- indixes of pixels to return
            % col_pix_idx -- if not empty, the indices of the pixel field
            %                to return, if empty, all pixels field
            % Output:
            % pix_data    -- [9,numel(row_pix_idx)] array of pixel data
            if isempty(obj.data_)
                pix_data = obj.EMPTY_PIXELS;
                return
            end
            if isempty(col_pix_idx)
                pix_data = obj.data_(:, row_pix_idx);
            else
                pix_data = obj.data_(ind_in_pix, row_pix_idx);
            end

        end
        function [obj,unique_id]=calc_page_range(obj,field_name)
            % Calculate and set range of pixel data, for block of pixels
            % stored in memory.
            % The coordinates are defined by the selected field
            %
            % Sets up the property page_range defining the range of block
            % of pixels changed at current iteration.

            if isempty(obj.data_)
                unique_id = [];
                return
            end
            ind = obj.field_index(field_name);
            obj.data_range_(:,ind)   = PixelDataBase.EMPTY_RANGE(:,ind);

            if nargout==2
                [obj,unique_id] = calc_page_range@PixelDataBase(obj,ind);
            else
                obj = calc_page_range@PixelDataBase(obj,ind);
            end
        end

        function obj = set_alignment_matrix(obj,val)
            % set new alignment matrix and recalculate new pixel ranges
            % if alignment changes
            obj = obj.set_alignment(val,@calc_page_range);
        end
        function num_pix = get_num_pixels(obj)
            % num_pixels getter
            num_pix = size(obj.data_,2);
        end
        function ro = get_read_only(~)
            % pixel data in memory are not read-only
            ro = false;
        end
        %
        function prp = get_prop(obj, fld)
            prp = get_prop_(obj, fld);
        end
        function obj=set_prop(obj, fld, val)
            val = check_set_prop(obj,fld,val);
            idx = obj.FIELD_INDEX_MAP_(fld);
            obj.data_(idx, :) = val;

            % setting data property value removes misalignment. We do not
            % consciously set misaligned data
            if obj.is_misaligned_
                obj.is_misaligned_ = false;
                obj.alignment_matr_= eye(3);
            end
            obj=obj.calc_page_range(fld);
        end
        %
        function data  = get_data(obj,varargin)
            % main part of data getter
            data = obj.data_;
            if obj.is_misaligned_
                pix_coord = obj.alignment_matr_*data(1:3,:);
                data(1:3,:) = pix_coord;
            end
        end
        %
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
        %------------------------------------------------------------------
    end
    %----------------------------------------------------------------------
    % PAGING
    methods(Access=protected)
        function  page_size = get_page_size(obj)
            page_size = size(obj.data_,2);
        end
        function np = get_page_num(~)
            np = 1;
        end
        function obj = set_page_num(obj,varargin)
            % do nothing. Only 1 is pagenum in pixel_data
        end
        function np = get_num_pages(~)
            np = 1;
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
