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
    %   >> signal = pix_data.get_fields('signal');
    %
    %  To retrieve multiple fields of data, e.g. run_idx and energy_idx, for pixels 1 to 10:
    %
    %   >> pix_data = PixelDataFileBacked(data);
    %   >> signal = pix_data.get_fields({'run_idx', 'energy_idx'}, 1:10);
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
    %   >>     pix = pix.advance();
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
    %   data_range      - [2x9] array of the range of data coordinates, including
    %                     pix coordinates in Crystal Cartesian coordinate system.
    %
    %   data           - The raw pixel data - usage of this attribute is discouraged, the structure
    %                    of the return value is not guaranteed.
    %

    properties (Access=private)
        num_pixels_ = 0;  % number of pixels, stored in the data file
        f_accessor_ = []; % instance of object to access pixel data from file
        page_num_   = 1;  % the index of the currently loaded page
        offset_ = 0;
    end

    properties (Constant)
        is_filebacked = true;
    end

    % =====================================================================
    % Overloaded operations interface
    methods
        function obj = append(obj, ~)
            error('HORACE:PixelDataFileBacked:not_implemented',...
                'append does not work on file-based pixels')
        end

        function obj = set_raw_data(obj,pix)
            if obj.read_only
                error('HORACE:PixelDataFileBacked:runtime_error',...
                    'set_raw_data is not currently implemented on file-based pixels')
            end
            obj = set_raw_data_(obj,pix);
        end

        function obj  = set_fields(obj, data, fields, varargin)
            if obj.read_only
                error('HORACE:PixelDataFileBacked:runtime_error',...
                    'set_fields can not run on read-only PixelDataFileBacked')
            end
            obj = set_fields@PixelDataBase(obj, data, fields, varargin{:});
        end

        [mean_signal, mean_variance] = compute_bin_data(obj, npix);

        pix_out = do_unary_op(obj, unary_op);
        pix_out = do_binary_op(obj, operand, binary_op, varargin);
        [ok, mess] = equal_to_tol(obj, other_pix, varargin);


        pix_out = get_pixels(obj, abs_pix_indices,varargin);
        pix_out = get_fields(obj, fields, abs_pix_indices);

        function  obj=set_raw_fields(obj, data, fields, varargin)
            if obj.read_only
                error('HORACE:PixelDataFileBacked:not_implemented',...
                      'set_raw_fields can not run on read-only PixelDataFileBacked')
            end
            obj = set_raw_fields_(obj, data, fields, varargin{:});
        end
    end

    methods
        function obj = PixelDataFileBacked(varargin)
            % Construct a File-backed PixelData object from the given data.
            % construction initialises the underlying data as an empty (9 x 0)
            % array.

            if nargin == 0
                return
            end
            obj = obj.init(varargin{:});
        end

        function obj = init(obj, varargin)
            % Main part of the fileBacked constructor
            %
            obj = init_(obj,varargin{:});
        end

        function obj = move_to_first_page(obj)
            % Reset the object to point to the first page of pixel data in the file
            % and clear the current cache
            %  This function does nothing if pixels are not file-backed.
            %
            obj.page_num_ = 1;
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
            % recalc_data_range is a normal Matlab value object (not a handle object),
            % returning its changes in LHS

            obj.data_range_ = PixelDataBase.EMPTY_RANGE;
            obj = obj.move_to_first_page();
            ic = 0;
            unique_pix_id = [];

            for i = 1:obj.num_pages
                obj.page_num_ = i;

                if obj.num_pages > 20 && mod(i, 10) == 0
                    fprintf(2,'*** processing block N:%d/%d\n', ...
                        obj.page_num_,obj.num_pages)
                end

                if nargout > 1
                    [obj,unique_id]=obj.reset_changed_coord_range('all');
                    unique_pix_id = unique([unique_pix_id,unique_id]);
                else
                    obj=obj.reset_changed_coord_range('all');
                end
            end
        end

        % --- Operator overrides ---
        function obj=delete(obj)
            % method tries to clear up the class instance to allow
            % class file beeing deleted when this class goes out of scope.
            % Depending on Matlab version, it may not work.
            mmf = obj.f_accessor_;
            clear mmf;
            obj.f_accessor_ = [];
            clear obj.f_accessor_;
        end

        function saveobj(~)
            error('HORACE:PixelData:runtime_error',...
                'Can not save filebacked PixelData object');
        end

    end

    %======================================================================
    % PAGING
    methods(Access=protected)
        function [pix_idx_start, pix_idx_end] = get_page_idx_(obj, page_number)
            if ~exist('page_number', 'var')
                page_number = obj.page_num_;
            end

            pgs = obj.page_size;
            pix_idx_start = (page_number -1)*pgs+1;

            if obj.num_pixels > 0 && pix_idx_start > obj.num_pixels
                error('HORACE:PixelDataFileBacked:runtime_error', ...
                    'pix_idx_start exceeds number of pixels in file. %i >= %i', ...
                    pix_idx_start, obj.num_pixels);
            end

            % Get the index of the final pixel to read given the maximum page size
            pix_idx_end = min(pix_idx_start + pgs - 1, obj.num_pixels);
        end

        function np = get_page_num(obj)
            np = obj.page_num_;
        end

        function obj = set_page_num(obj,val)
            if ~isnumeric(val) || ~isscalar(val) || val<1
                error('HORACE:PixelDataFileBacked:invelid_argument', ...
                    'page number should be positive numeric scalar. It is: %s',...
                    disp2str(val))
            elseif val > obj.num_pages
                error('HORACE:PixelDataFileBacked:invelid_argument', ...
                    'page number (%d) should not be bigger then total number of pages: %d',...
                    val,obj.num_pages);
            end

            obj.page_num_ = val;
        end

        function page_size = get_page_size(obj)
            page_size = min(config_store.instance().get_value('hor_config','mem_chunk_size'),obj.num_pixels);
        end

        function np = get_num_pages(obj)
            np = max(ceil(obj.num_pixels/obj.page_size),1);
        end

        function  data =  get_raw_data(obj,page_number)
            if ~exist('page_number', 'var')
                page_number = obj.page_num_;
            end

            if isempty(obj.f_accessor_)
                prp = obj.EMPTY_PIXELS;
            else
                [pix_idx_start, pix_idx_end] = obj.get_page_idx_(page_number);
                data = double(obj.f_accessor_.Data.data(:,pix_idx_start:pix_idx_end));
            end

        end
    end
    %======================================================================
    % other getter/setter
    methods (Access = protected)
        function num_pix = get_num_pixels(obj)
            % num_pixels getter
            num_pix = obj.num_pixels_;
        end

        function ro = get_read_only(obj)
            % report if the file allows to be modified.
            % Main overloadable part of read_only property
            ro = isempty(obj.f_accessor_) || ~obj.f_accessor_.Writable;
        end

        %------------------------------------------------------------------
        function obj=set_data_wrap(obj,val)
            % main part of pix_data_wrap setter overloaded for
            % PixDataFileBacked class
            if ~isa(val,'pix_data')
                error('HORACE:PixelDataFileBacked:invalid_argument', ...
                    'pix_data_wrap property can be set by pix_data class instance only. Provided class is: %s', ...
                    class(val));
            elseif ~(ischar(val.data)||isstring(val.data)||isempty(val.data))
                error('HORACE:PixelDataFileBacked:invalid_argument', ...
                    'Attempt to initialize PixelDataFileBacked using pix_data values obtained from PixelDataMemory class: %s', ...
                    disp2str(val));
            end

            in_file = val.data;

            if isempty(in_file)
                return;
            end

            if ~is_file(in_file)
                if MPI_State.instance().is_deployed
                    error('HORACE:PixelDataFileBacked:invalid_argument', ...
                        'Cannot find file-source of file-backed pixel data: %s', in_file)
                else
                    mess = sprintf('Cannot find file-source of file-backed pixels: %s. Select sqw file to get pixel data from', ...
                        in_file);
                    in_file = getfile(in_file, mess);
                    if isempty(in_file)
                        error('HORACE:PixelDataFileBacked:invalid_argument', ...
                            'File-source of file-backed pixel data: %s have not been found.', in_file)
                    end
                end
            end

            ldr = sqw_formats_factory.instance().get_loader(in_file);
            obj = init_from_file_accessor_(obj,ldr,false,true);
        end

        function prp = get_prop(obj, fld)
            [pix_idx_start, pix_idx_end] = obj.get_page_idx_(obj.page_num_);

            if isempty(obj.f_accessor_)
                prp = zeros(obj.get_field_count(fld), 0);
            else
                prp = double(obj.f_accessor_.Data.data(obj.FIELD_INDEX_MAP_(fld), ...
                    pix_idx_start:pix_idx_end));
            end
        end

        function obj=set_prop(obj, fld, val)
            val = check_set_prop(obj,fld,val);
            if ~obj.f_accessor_.Writable
                error('HORACE:PixelDataFileBacked:invalid_argument',...
                    'File %s is opened in read-only mode',obj.full_filename);
            end

            [pix_idx_start,pix_idx_end] = obj.get_page_idx_(obj.page_num_);
            pix_idx_end = min(pix_idx_end,pix_idx_start-1+size(val,2));
            indx = pix_idx_start:pix_idx_end;
            flds = obj.FIELD_INDEX_MAP_(fld);
            obj.f_accessor_.Data.data(flds, indx) = single(val);

            % this operation will probably lead to invalid results.
            obj=obj.reset_changed_coord_range(fld);
        end

        function [obj,unique_idx]=reset_changed_coord_range(obj,field_name)
            % Recalculate and set appropriate range of pixel coordinates.
            % The coordinates are defined by the selected field
            %
            % Sets up the property page_range defining the range of block
            % of pixels changed at current iteration.

            %NOTE:  This range calculations are incorrect unless
            %       performed in a loop over all pix pages where initial
            %       range is set to empty!
            %
            if iscell(field_name)
                ind = obj.check_pixel_fields(field_name);
            else
                ind = obj.FIELD_INDEX_MAP_(field_name);
            end

            loc_range = [min(obj.data(ind,:),[],2),...
                         max(obj.data(ind,:),[],2)]';

            range = minmax_ranges(obj.data_range_(:,ind),loc_range);
            obj.data_range_(:,ind)  = range;
            if nargout > 1
                unique_idx = unique(obj.run_idx);
            end
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
                obj = PixelDataFileBacked();
                obj = loadobj@serializable(S,obj);
            else
                obj = loadobj@PixelDataBase(S);
            end

        end
    end

end
