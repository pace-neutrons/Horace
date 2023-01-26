classdef PixelDataMemory < PixelDataBase
    % PixelDataMemory Provides an interface for access to memory-backed pixel data
    %
    %   This class provides getters and setters for each data column in an SQW
    %   pixel array. You can access the data using the attributes listed below,
    %   using the get_data() method (to retrieve column data) or using the
    %   get_pixels() method (retrieve row data).
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
    %   >> signal = pix_data.get_data('signal');
    %
    %  To retrieve multiple fields of data, e.g. run_idx and energy_idx, for pixels 1 to 10:
    %
    %   >> pix_data = PixelDataMemory(data);
    %   >> signal = pix_data.get_data({'run_idx', 'energy_idx'}, 1:10);
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
        %
        [mean_signal, mean_variance] = compute_bin_data(obj, npix);
        pix_out = do_binary_op(obj, operand, binary_op, varargin);
        pix_out = do_unary_op(obj, unary_op);
        [ok, mess] = equal_to_tol(obj, other_pix, varargin);

        pix_out = get_pix_in_ranges(obj, abs_indices_starts, block_sizes,...
            recalculate_pix_ranges,keep_precision);
        pix_out = get_pixels(obj, abs_pix_indices);
        pix_out = mask(obj, mask_array, npix);
        pix_out = noisify(obj, varargin);
        %
        pix_out = get_data(obj, fields, abs_pix_indices);
        obj=set_data(obj, data, fields, abs_pix_indices);
    end

    methods
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

        function obj = PixelDataMemory(varargin)
            % Construct a PixelDataMemory object from the given data. Default
            % construction initialises the underlying data as an empty (9 x 0)
            % array.
            %
            if nargin == 0
                return
            end
            if nargin > 1
                % build from data/metadata pair
                flds = obj.saveableFields();
                obj = obj.set_positional_and_key_val_arguments(...
                    flds,false,varargin);
                return
            else
                init = varargin{1};
            end


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
                obj.data = init.data;

            elseif isscalar(init) && isnumeric(init) && floor(init) == init
                % input is an integer
                obj.data = zeros(obj.PIXEL_BLOCK_COLS_, init);

            elseif isnumeric(init)
                obj.data = init;

            elseif isa(init, 'PixelDataFileBacked')
                init=init.move_to_first_page();
                obj.data_ = init.data;
                while init.has_more()
                    init = init.advance();
                    obj.data_ = horzcat(obj.data_, init.data);
                end

                obj.full_filename = init.full_filename;
                obj=obj.reset_changed_coord_range();
            else
                error('HORACE:PixelDataMemory:invalid_argument', ...
                    'Cannot construct PixelDataMemory from class (%s)', class(init))
            end
        end

        % --- Data management ---
        function has_more = has_more(~)
            % Returns true if there are subsequent pixels stored in the file that
            % are not held in the current page
            %
            %    >> has_more = pix.has_more();
            %
            has_more = false;
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

        function [current_page_num, total_num_pages] = advance(~, varargin)
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
    end
    %
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
        function data =  get_data_(obj)
            % main part of get.data accessor
            data = obj.data_;
        end
        %
        %
        function num_pix = get_num_pixels(obj)
            % num_pixels getter
            num_pix = size(obj.data_,2);
        end
        %------------------------------------------------------------------
        function obj=set_prop(obj, fld, val)
            val = check_set_prop(obj,fld,val);
            obj.data_(obj.FIELD_INDEX_MAP_(fld), :) = val;
            obj=obj.reset_changed_coord_range(fld);
        end
        %
        function prp = get_prop(obj, fld)
            prp = obj.data_(obj.FIELD_INDEX_MAP_(fld), :);
        end
        %
        function obj = init_from_file_accessor_(obj, f_accessor)
            % Initialise a PixelData object from a file accessor
            obj.data_range_ = f_accessor.get_data_range();
            obj.data_ = f_accessor.get_raw_pix();
            obj.full_filename = f_accessor.full_filename;
            undef = obj.data_range == PixelDataBase.EMPTY_RANGE;
            if any(undef(:))
                obj = obj.reset_changed_coord_range('all');
            end
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
            ind = obj.FIELD_INDEX_MAP_(field_name);

            range = [min(obj.data_(ind,:),[],2),max(obj.data_(ind,:),[],2)]';
            obj.data_range_(:,ind)   = range(:,ind);
            if nargout>1
                varargout{1} =  unique(obj.run_idx);
            end
        end
        %------------------------------------------------------------------
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
end
