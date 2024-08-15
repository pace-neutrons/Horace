classdef (InferiorClasses = {?DnDBase,?IX_dataset,?sigvar}) PixelDataFileBacked < PixelDataBase
    % PixelDataFileBacked Provides an interface for access to file-backed pixel data.
    % Each pixel is representation of neutron event, i.e. neutron or group of neutron
    % recorded in inelastic neutron experiment
    %
    % This class provides getters and setters for each data column in an SQW
    % pixel array. You can access the data using the attributes listed below,
    % using the get_data() method (to retrieve column data) or using the
    % get_pixels() method (retrieve row data).
    %
    % Construct this class with an 9 x N array, a file path to an SQW object or
    % an instance of sqw_binfile_common.
    %
    % >> pix_data = PixelDataFileBacked(data);
    % >> pix_data = PixelDataFileBacked('/path/to/sqw.sqw');
    % >> pix_data = PixelDataFileBacked(faccess_obj);
    %
    % No pixel data will be loaded from the file on construction.
    % Data will be loaded when a getter is called e.g. pix_data.signal. Data will
    % be loaded in pages such that the data held in memory will not exceed `mem_chunk_size`
    %
    % The file-backed operations work by loading "pages" of data into memory as
    % required. If editing pixels, to avoid losing changes, if a page has been
    % edited and the next page is then loaded, the "dirty" page will be written
    % to a tmp file. This class's getters will then retrieve data from the tmp
    % file if that data is requested from the "dirty" page. Note that "dirty"
    % pages are written to tmp files as floats, but stored in memory as double.
    % This means data is truncated when moving pages, hence pixel data should not
    % be relied upon being accurate to double precision.
    %
    % Usage:
    %
    %   >> pix_data = PixelDataFileBacked(data)
    %   >> signal = pix_data.signal;
    %
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
    %                    Cartesian coordinates of neutron events described by pixels. Units are per Angstrom (1 x n arrays)
    %   dE             - The energy transfer value for each event in meV (1 x n array)
    %   coordinates    - Four coordinates of the pixel data [u1, u2, u3, dE] (4 x n array)
    %   q_coordinates  - Three Q-space coordinates of the pixel data [u1, u2, u3] (3 x n array)
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
        page_num_   = 1;  % the index of the currently referenced page

        % shift (in Bytes) from the beginning of the binary file containing
        % the pixels to the first byte of pixels to access. Also used
        % by `distribute` to send file portions to workers
        offset_ = 0;

        % Place for handle-class holding tmp pixel file produced by filebacked
        % operations with pixels only (no sqw object). If all referring
        % classes go out of scope the file gets deleted. See similar
        % property on SQW object for operations with full sqw object.
        tmp_file_holder_ = [];
    end

    properties(Dependent,Hidden)
        % defines offset from the beginning of the pixels in the binary file
        % accessed through memmapfile.
        offset;
    end
    properties (Constant)
        is_filebacked = true;
    end

    % =====================================================================
    % Overloaded operations interface
    methods
        function obj = set_raw_data(obj,pix)
            %SET_RAW_DATA set internal data array without comprehensive checks for
            % data integrity and data ranges.
            %
            % Performance method, which invalidates object integrity,
            % so further operations are necessary to keep object intact.
            % Invalidates data ranges which need recalculation/settings
            % separately
            %
            if obj.read_only
                error('HORACE:PixelDataFileBacked:runtime_error',...
                    'File %s is opened in read-only mode.', obj.full_filename);
            end
            obj = set_raw_data_(obj,pix);
        end
    end

    methods
        function obj = PixelDataFileBacked(varargin)
            % Construct a File-backed PixelData object from the given data.
            %
            % Empty construction initialises the underlying data as an empty (9 x 0)
            % array.
            if nargin == 0
                return
            end
            obj = obj.init(varargin{:});
        end

        function obj = init(obj, varargin)
            % Main part of the fileBacked constructor.
            %
            % Initialize filebacked data using any available input
            % information namely:
            % >> fb = PixelDataFileBacked();
            %
            % 1:>> fb = fb.init(filename);
            % 2:>> fb = fb.init(struct);
            % 3:>> fb = fb.init(pixel_data_wrap,pixel_metadata);
            % 4:>> fb = fb.init(other_PixelDataFileBacked);
            % 5:>> fb = fb.init(instance_PixelDataMemory);
            % 6:>> fb = fb.init(faccess_loader);
            % Normally test mode:
            % 7:>> fb = fb.init(number);
            % 8:>> fb = fb.init(3xNpix array);
            % Where
            % 1: filename -- the name of existing sqw file
            % 2: struct   -- the structure obtained from serializable
            %                to_struct method, saveobj method or previous
            %                versions of these methods.
            % 3: pixel_data_wrap -- class-wrapper around pixel data information,
            %                       obtained from obj.data_wrap property
            %    pixel_metadata  -- class-wrapper around pixel metadata
            %                       information obtained from obj.metadata
            %                       property
            % 4: other_PixelDataFileBacked
            %             -- build PixelDataFileBacked from other instance
            %                  of PixelDataFileBacked class
            % 5: instance_PixelDataMemory
            %             -- build PixelDataFileBacked from instance
            %                of PixelDataMemory class
            % 6: faccess_loader
            %             -- initialized instance of binary faccess_sqw
            %                 file loader
            % 7: number   -- initialized single-paged data class with the
            %                  provided number of empty pixels
            % 8: memmapfile
            %             -- instance of memmapfile, initialized to access
            %                pixel data
            % 9: 3xNpix array
            %             -- initialize filebacked class from array of
            %                data provided as input

            obj = init_(obj,varargin{:});
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
            % recalc_data_range is a normal MATLAB value object (not a handle object),
            % returning its changes in LHS

            if nargin == 1
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
                    [obj,unique_id] = obj.calc_page_range(fld);
                    unique_pix_id = unique([unique_pix_id,unique_id]);
                else
                    obj = obj.calc_page_range(fld);
                end
            end
        end

        % --- Operator overrides ---
        function obj = delete(obj)
            % method tries to clear up the class instance to allow
            % class file being deleted when this class goes out of scope.
            % Depending on MATLAB version, it may not work.
            mmf = obj.f_accessor_;
            clear mmf;
            obj.f_accessor_ = [];
            clear obj.f_accessor_;
        end

        function saveobj(~)
            error('HORACE:PixelData:runtime_error',...
                'Can not save filebacked PixelData object');
        end

        % public getter for unmodified page data
        data =  get_raw_data(obj,varargin)

        function offset = get.offset(obj)
            offset = obj.offset_;
        end
    end

    %======================================================================
    % File handling/migration
    methods
        function obj = deactivate(obj)
            % close all open file handles to allow file movements to new
            % file/new location.
            obj = deactivate_(obj);
        end
        function [obj,is_tmp] = activate(obj,filename,varargin)
            % open file access for file, previously closed by deactivate
            % operation, possibly using new file name
            %
            % Optional:
            % no_tmp_file  -- if present and true, do not set file with
            %                 extension .tmp_ as temporary file
            if nargin == 1 || isempty(filename)
                filename = obj.f_accessor_.full_filename;
            end
            [obj,is_tmp] = activate_(obj,filename,varargin{:});
        end

        function wh = get_write_handle(obj,varargin)
            targ_fn = PixelDataBase.build_op_filename(obj.full_filename,varargin{:});
            wh = pix_write_handle(targ_fn);
        end
        %
        function obj = store_page_data(obj,data,wh)
            wh.save_data(data);
        end
        function obj =set_as_tmp_obj(obj,filename)
            % mark object's file for deletion when this class goes out of
            % scope
            obj = set_as_tmp_obj_(obj,filename);
        end
        %
        function obj = finish_dump(obj,page_op)
            % complete pixel write operation, close writing to the target
            %  file and open pixel dataset for access operations.
            obj = finish_dump_(obj,page_op);
        end

        function format = get_memmap_format(obj, tail,new)
            if isempty(obj.f_accessor_) || ~isa(obj.f_accessor_,'memmapfile') || ...
                    (nargin==3 && new)
                if nargin == 1
                    tail = 0;
                end
                format = PixelDataBase.get_memmap_format(obj.num_pixels_,tail);
            else
                format = obj.f_accessor_.Format;
            end
        end

        function obj = move_to_first_page(obj)
            % Reset the object to point to the first page of pixel data in the file
            % and clear the current cache
            obj.page_num_ = 1;
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
        function pix_copy = copy(obj)
            pix_copy = obj;
            if ~isempty(obj.tmp_file_holder_)
                obj.tmp_file_holder_.copy();
            end
            pix_copy.page_num = 1;
        end
        %
        function   sz = get_pix_byte_size(obj,keep_precision)
            % Return the size of single pixel expressed in bytes.
            %
            % If keep_percision is true, return this size as defined in
            % pixel data file
            if nargin<2
                keep_precision = obj.keep_precision;
            end
            if keep_precision
                sz = obj.DEFAULT_NUM_PIX_FIELDS*4;
            else
                sz = obj.DEFAULT_NUM_PIX_FIELDS*8;
            end
        end
    end
    %======================================================================
    methods(Static)
        % apply page operation(s) to the object with File-backed pixels
        obj_out = apply_op(obj_in,page_op);
        %
    end

    %======================================================================
    % implementation of PixelDataBase abstract protected interface
    methods (Access = protected)
        function is = get_is_tmp_obj(obj)
            is = ~isempty(obj.tmp_file_holder_);
        end

        function full_filename = get_full_filename(obj)
            if isempty(obj.tmp_file_holder_)
                full_filename = obj.full_filename_;
            else
                full_filename = obj.tmp_file_holder_.file_name;
            end
        end
        function obj =  set_metadata(obj,val)
            % main part of set from metadata setter
            obj = set_metadata@PixelDataBase(obj,val);
            obj.num_pixels_ = val.npix;
        end


        function pix_data = get_raw_pix_data(obj,row_pix_idx,col_pix_idx)
            % Overloaded part of get_raw_pix operation.
            %
            % return unmodified pixel data according to the input indexes
            % provided.
            % Inputs:
            % obj         -- initialized pixel data memory object
            % row_pix_idx -- indices of pixels to return
            % col_pix_idx -- if not empty, the indices of the pixel field
            %                to return, if empty, all pixels fields
            % Output:
            % pix_data    -- [9,numel(row_pix_idx)] array of pixel data
            mmf = obj.f_accessor_;
            if isempty(mmf)
                pix_data = obj.EMPTY_PIXELS;
                return
            end

            % Return raw pixels
            if isempty(col_pix_idx)
                pix_data = mmf.Data.data(:,row_pix_idx);
            else
                pix_data = mmf.Data.data(col_pix_idx,row_pix_idx);
            end

        end

        function data_range = get_data_range(obj,varargin)
            % overloadable data range getter
            if nargin == 1
                data_range = obj.data_range_;
            else
                idx = obj.field_index(varargin{1});
                data_range = obj.data_range_(:,idx);
            end
        end

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
        function prp = get_prop(obj, fld)
            % main part of PixelData property getter;
            prp = get_prop_(obj,fld);
        end
        function obj = set_prop(obj, fld, val)
            obj = set_prop_(obj,fld,val);
        end
        %
        function obj=set_data_wrap(obj,val)
            % main part of pix_data_wrap setter overloaded for
            % PixDataFileBacked class
            if ~isa(val,'pix_data')
                error('HORACE:PixelDataFileBacked:invalid_argument', ...
                    'pix_data_wrap property can be set by pix_data class instance only. Provided class is: %s', ...
                    class(val));
            end
            if isempty(val.data)
                return;
            elseif isnumeric(val.data)
                init = val.data;
            elseif istext(val.data)
                % File-backed or loader construction
                % input is a file path
                init = sqw_formats_factory.instance().get_loader(val.data);
            end
            obj = obj.init(init);
        end
        %------------------------------------------------------------------
        function data  = get_data(obj,page_number)
            if nargin==1
                page_number = 1;
            end
            data =  obj.get_raw_data(page_number);
            if obj.is_misaligned_
                data(1:3,:) = obj.alignment_matr_*data(1:3,:);
            end
        end
        %------------------------------------------------------------------
        function obj = set_alignment_matrix(obj,val)
            % set non-unary alignment martix and invalidate pixel averages
            % if alignment changes
            obj = obj.set_alignment(val,@invalidate_range);
        end
    end
    %----------------------------------------------------------------------
    % PAGING
    methods(Access=protected)
        function np = get_page_num(obj)
            np = obj.page_num_;
        end

        function obj = set_page_num(obj,val)
            val = floor(val);
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
            page_size = min(obj.default_page_size, obj.num_pixels);
        end

        function np = get_num_pages(obj)
            np = max(ceil(obj.num_pixels/obj.page_size),1);
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
