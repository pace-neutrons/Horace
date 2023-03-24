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
    %   >> for i = 1:pix.num_pages
    %   >>     pix.page_num = i;
    %   >>     signal_sum = signal_sum + pix.signal;
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
        file_handle_ = [];
        tmp_pix_obj = [];
    end

    properties(Dependent)
        offset;
    end

    properties (Constant)
        is_filebacked = true;
    end

    % =====================================================================
    % Overloaded operations interface
    methods
        function obj = append(~, ~)
            error('HORACE:PixelDataFileBacked:not_implemented',...
                'append does not work on file-based pixels')
        end

        function obj = set_raw_data(obj,pix)
            if obj.read_only
                error('HORACE:PixelDataFileBacked:runtime_error',...
                    'File %s is opened in read-only mode', obj.full_filename);
            end
            obj = set_raw_data_(obj,pix);
        end

        obj=set_raw_fields(obj, data, fields, varargin)
        [mean_signal, mean_variance] = compute_bin_data(obj, npix);

        pix_out = do_unary_op(obj, unary_op);
        pix_out = do_binary_op(obj, operand, binary_op, varargin);
        [ok, mess] = equal_to_tol(obj, other_pix, varargin);

        pix_out = get_pixels(obj, abs_pix_indices,varargin);
        pix_out = get_fields(obj, fields, abs_pix_indices);
        pix_out = mask(obj, mask_array, varargin);

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

            % process possible update parameter
            is_bool = cellfun(@islogical,varargin);
            log_par = [varargin{is_bool} false(1,2)]; % Pad with false
            update  = log_par(1);
            norange = log_par(2);
            argi = varargin(~is_bool);

            if isscalar(argi)
                init = argi{1};
            else
                % build from data/metadata pair
                init = argi;
            end

            if iscell(init)
                flds = obj.saveableFields();
                obj = obj.set_positional_and_key_val_arguments(flds,false,argi);

            elseif isstruct(init)
                obj = obj.loadobj(init);

            elseif isa(init, 'PixelDataFileBacked')
                obj.offset_       = init.offset_;
                obj.full_filename = init.full_filename;
                obj.num_pixels_   = init.num_pixels;
                obj.data_range    = init.data_range;
                obj.tmp_pix_obj   = init.tmp_pix_obj;
                obj.f_accessor_   = memmapfile(obj.full_filename, ...
                                               'Format', obj.get_memmap_format(), ...
                                               'Repeat', 1, ...
                                               'Writable', update, ...
                                               'Offset', obj.offset_ );

            elseif isa(init, 'PixelDataMemory')

                if isempty(obj.full_filename_)
                    obj.full_filename = 'from_mem';
                end

                obj = set_raw_data_(obj,init.data);

            elseif istext(init)
                if ~is_file(init)
                    error('HORACE:PixelDataFileBacked:invalid_argument', ...
                        'Cannot find file to load (%s)', init)
                end

                init = sqw_formats_factory.instance().get_loader(init);
                obj = init_from_file_accessor_(obj,init,update,norange);

            elseif isa(init, 'sqw_file_interface')
                obj = init_from_file_accessor_(obj,init,update,norange);

            elseif isnumeric(init)
                % this is usually option for testing filebacked operations
                if isscalar(init)
                    init = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS,abs(floor(init)));
                end

                if isempty(obj.full_filename_)
                    obj.full_filename = 'from_mem';
                end

                obj = set_raw_data_(obj,init);
            else
                error('HORACE:PixelDataFileBacked:invalid_argument', ...
                    'Cannot construct PixelDataFileBacked from class (%s)', class(init))
            end

            obj.page_num = 1;
        end

        function obj = move_to_first_page(obj)
            % Reset the object to point to the first page of pixel data in the file
            % and clear the current cache
            %  This function does nothing if pixels are not file-backed.
            %
            obj.page_num_ = 1;
        end

        function [obj,unique_pix_id] = recalc_data_range(obj, fld)
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

            if ~exist('fld', 'var')
                fld = 'all';
            end

            obj.data_range_ = PixelDataBase.EMPTY_RANGE;
            unique_pix_id = [];

            for i = 1:obj.num_pages
                obj.page_num_ = i;

                if obj.num_pages > 20 && mod(i, 10) == 0
                    fprintf(2,'*** processing block N:%d/%d\n', ...
                        obj.page_num_,obj.num_pages)
                end

                if nargout > 1
                    [obj,unique_id] = obj.reset_changed_coord_range(fld);
                    unique_pix_id = unique([unique_pix_id,unique_id]);
                else
                    obj = obj.reset_changed_coord_range(fld);
                end
            end
        end

        % --- Operator overrides ---
        function obj = delete(obj)
            % method tries to clear up the class instance to allow
            % class file being deleted when this class goes out of scope.
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


        function [obj,unique_idx] = reset_changed_coord_range(obj,field_name)
            % Recalculate and set appropriate range of pixel coordinates.
            % The coordinates are defined by the selected field
            %
            % Sets up the property page_range defining the range of block
            % of pixels changed at current iteration.

            %NOTE:  This range calculations are incorrect unless
            %       performed in a loop over all pix pages where initial
            %       range is set to empty!
            %
            ind = obj.check_pixel_fields(field_name);

            obj.data_range_(:,ind) = obj.pix_minmax_ranges(obj.data(ind,:), ...
                                                           obj.data_range_(:,ind));
            if nargout > 1
                unique_idx = unique(obj.run_idx);
            end
        end

        function offset = get.offset(obj)
            offset = obj.offset_;
        end
    end

    %======================================================================
    % PAGING
    methods(Access=protected)

        function np = get_page_num(obj)
            np = obj.page_num_;
        end

        function obj = set_page_num(obj,val)
            if ~isnumeric(val) || ~isscalar(val) || val<1
                error('HORACE:PixelDataFileBacked:invalid_argument', ...
                    'page number should be positive numeric scalar. It is: %s',...
                    disp2str(val))
            elseif val > obj.num_pages
                error('HORACE:PixelDataFileBacked:invalid_argument', ...
                    'page number (%d) should not be bigger then total number of pages: %d',...
                    val, obj.num_pages);
            end

            obj.page_num_ = val;
        end

        function page_size = get_page_size(obj)
            page_size = min(obj.DEFAULT_PAGE_SIZE, obj.num_pixels);
        end

        function np = get_num_pages(obj)
            np = max(ceil(obj.num_pixels/obj.DEFAULT_PAGE_SIZE),1);
        end

        function data = get_raw_data(obj, page_number)
            if ~exist('page_number', 'var')
                page_number = obj.page_num_;
            end

            if isempty(obj.f_accessor_)
                data = obj.EMPTY_PIXELS;
            else
                [pix_idx_start, pix_idx_end] = obj.get_page_idx_(page_number);
                data = double(obj.f_accessor_.Data.data(:, pix_idx_start:pix_idx_end));
            end

        end

    end

    %======================================================================
    % File handling/migration
    methods
        function obj = get_new_handle(obj, f_accessor)

            % Always create a new PixTmpFile object
            % If others point to it, file will be kept
            % otherwise file will be cleared

            if exist('f_accessor', 'var') && ~isempty(f_accessor)
                obj.file_handle_ = f_accessor;
            else
                if isempty(obj.full_filename)
                    obj.full_filename = 'in_mem';
                end
                obj.tmp_pix_obj = TmpFileHandler(obj.full_filename);

                fh = fopen(obj.tmp_pix_obj.file_name, 'wb+');
                if fh<1
                    error('HORACE:PixelDataFileBacked:runtime_error', ...
                          'Can not open data file %s for file-backed pixels',...
                          obj.tmp_pix_obj.file_name);
                end

                obj.file_handle_ = fh;
            end

        end

        function format_dump_data(obj, pix, start_idx)
            if isempty(obj.file_handle_)
                error('HORACE:PixelDataFileBacked:runtime_error', ...
                    'Cannot dump data, object does not have open filehandle')
            end

            if isa(obj.file_handle_, 'sqw_file_interface')
                if ~exist('start_idx', 'var')
                    start_idx = obj.get_page_idx_();
                end
                obj.file_handle_.put_raw_pix(pix, start_idx);
            else
                fwrite(obj.file_handle_, single(pix), 'single');
            end

        end

        function obj = finalise(obj, final_num_pixels)
            if isempty(obj.file_handle_)
                error('HORACE:PixelDataFileBacked:runtime_error', ...
                      'Cannot finalise writing, object does not have open filehandle')
            end

            if exist('final_num_pixels', 'var')
                obj.num_pixels_ = final_num_pixels;
            end

            if isa(obj.file_handle_, 'sqw_file_interface')
                obj.full_filename = obj.file_handle_.full_filename;
                obj.file_handle_ = obj.file_handle_.put_pix_metadata(obj);
                % Force pixel update
                obj.file_handle_ = obj.file_handle_.put_num_pixels(obj.num_pixels);

                obj = obj.init_from_file_accessor_(obj.file_handle_, false, true);
                obj.file_handle_ = [];

            else
                fclose(obj.file_handle_);
                if obj.num_pixels_ == 0
                    obj = PixelDataMemory();
                    return;
                end

                obj.file_handle_ = [];
                obj.f_accessor_ = [];
                obj.offset_ = 0;
                obj.full_filename = obj.tmp_pix_obj.file_name;
                obj.f_accessor_ = memmapfile(obj.full_filename, ...
                                             'format', obj.get_memmap_format(), ...
                                             'Repeat', 1, ...
                                             'Writable', true, ...
                                             'offset', obj.offset_);

            end
        end

        function format = get_memmap_format(obj)
            format = {'single',[PixelDataBase.DEFAULT_NUM_PIX_FIELDS, obj.num_pixels_],'data'};
        end

    end

    methods(Static)
        function obj = cat(varargin)
        % Concatenate the given PixelData objects' pixels. This function performs
        % a straight-forward data concatenation.
        %
        %   >> joined_pix = PixelDataBase.cat(pix_data1, pix_data2);
        %
        % Input:
        % ------
        %   varargin    A cell array of PixelData objects
        %
        % Output:
        % -------
        %   obj         A PixelData object containing all the pixels in the inputted
        %               PixelData objects

            if numel(varargin) <= 1 && ...
                    all(cellfun(@(x) isa(x, 'PixelDataBase'), varargin))
                obj = PixelDataFileBacked(varargin{1});
                return;
            end

            is_ldr = cellfun(@(x) isa(x, 'sqw_file_interface'), varargin);
            if any(is_ldr)
                ldr = varargin{is_ldr};
                varargin = varargin(~is_ldr);
            else
                ldr = [];
            end

            obj = PixelDataFileBacked();

            obj.num_pixels_ = sum(cellfun(@(x) x.num_pixels, varargin));

            obj = obj.get_new_handle(ldr);

            start_idx = 1;
            for i = 1:numel(varargin)
                curr_pix = varargin{i};
                for page = 1:curr_pix.num_pages
                    [curr_pix,data] = curr_pix.load_page(page);
                    obj.format_dump_data(data, start_idx);
                    start_idx = start_idx + size(data,2);
                end
            end

            obj = obj.finalise();
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

        function obj = set_data_wrap(obj,val)
            % main part of pix_data_wrap setter overloaded for
            % PixDataFileBacked class
            if ~isa(val,'pix_data')
                error('HORACE:PixelDataFileBacked:invalid_argument', ...
                    'pix_data_wrap property can be set to pix_data class instance only. Provided class is: %s', ...
                    class(val));
            elseif ~(istext(val.data) || isempty(val.data))
                error('HORACE:PixelDataFileBacked:invalid_argument', ...
                    'Attempt to initialize PixelDataFileBacked using invalid pix_data values: %s', ...
                    disp2str(val));
            end

            in_file = val.data;

            if isempty(in_file)
                return;
            end

            if ~is_file(in_file)
                error('HORACE:PixelDataFileBacked:invalid_argument', ...
                    'Cannot find file for file-backed pixel data: %s', in_file)
            end

            ldr = sqw_formats_factory.instance().get_loader(in_file);

            obj.full_filename = in_file;
            obj.offset_ = val.offset;
            obj.num_pixels_ = val.npix;
            obj.f_accessor_ = memmapfile(obj.full_filename, ...
                                         'Format', obj.get_memmap_format(), ...
                                         'Repeat', 1, ...
                                         'Writable', false, ...
                                         'Offset', obj.offset_);
            obj.page_num_ = 1;
            fac_range  = ldr.get_data_range();
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

        function obj = set_prop(obj, fld, val)
            if obj.read_only
                error('HORACE:PixelDataFileBacked:invalid_argument',...
                    'File %s is opened in read-only mode', obj.full_filename);
            end
            val = check_set_prop(obj,fld,val);

            [pix_idx_start,pix_idx_end] = obj.get_page_idx_(obj.page_num_);
            pix_idx_end = min(pix_idx_end,pix_idx_start-1+size(val,2));
            indx = pix_idx_start:pix_idx_end;
            flds = obj.FIELD_INDEX_MAP_(fld);
            obj.f_accessor_.Data.data(flds, indx) = single(val);

            % this operation will probably lead to invalid results.
            obj=obj.reset_changed_coord_range(fld);
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
