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
        page_num_   = 1;  % the index of the currently referred page

        % shift (in Bytes) from the beginning of the binary file containing
        % the pixels to the first byte
        offset_ = 0;

        % handle to the class used to perform pixel
        write_handle_ = []; % copying in operations, involving all pixels

        % handle-class holding tmp file, produced by filebacked
        % operations. If all referring classes go out of scope, the file
        % gets deleted
        tmp_file_holder_ = [];
    end

    properties(Dependent,Hidden)
        % defines offset from the beginning of the pixels in the binary file
        % accessed through memmapfile.
        offset;
    end

    properties(Dependent, Hidden)
        has_open_file_handle;
    end

    properties (Hidden, Access=private)
        pix_written = 0;
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
        % apply function represented by handle to every pixel of the dataset
        % and calculate appropriate averages if requested
        [obj, data] = apply(obj, func_handle, args, data, compute_variance);

        function obj = set_raw_data(obj,pix)
            %SET_RAW_DATA set internal data array without comprehensive checks for
            % data integrity and data ranges.
            % 
            % Performance method, which 
            % invalidates object integrity, so further operations are necessary
            % to keep object intact
            %
            if obj.read_only
                error('HORACE:PixelDataFileBacked:runtime_error',...
                    'File %s is opened in read-only mode.', obj.full_filename);
            end
            obj = set_raw_data_(obj,pix);
        end

        [pix_out, data] = do_unary_op(obj, unary_op, data);
        pix_out = do_binary_op(obj, operand, binary_op, varargin);
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
            % 3: pixel_data_wrap -- class-wrapper around pixel data informaion,
            %                       obtained from obj.data_wrap property
            %    pixel_metadata  -- class-wrapper aroung pixel metadata
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
            % 8: 3xNpix array
            %             -- initialize filebacked class from array of
            %                data provided as input

            % process possible update parameter
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
            % recalc_data_range is a normal Matlab value object (not a handle object),
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

        % public getter for unmodified page data
        data =  get_raw_data(obj,varargin)

        function offset = get.offset(obj)
            offset = obj.offset_;
        end

        function has = get.has_open_file_handle(obj)
            has = ~isempty(obj.write_handle_);
        end
    end

    %======================================================================
    % File handling/migration
    methods
        function obj = prepare_dump(obj)
            % Get new handle iff not already opened by sqw
            if ~obj.has_open_file_handle
                obj = obj.get_new_handle();
            end
        end

        function obj = get_new_handle(obj, f_accessor)
            % Always create a new PixTmpFile object
            % If others point to it, file will be kept
            % otherwise file will be cleared

            if exist('f_accessor', 'var') && ~isempty(f_accessor)
                obj.write_handle_ = f_accessor;
                obj.full_filename = f_accessor.full_filename;
            else
                if isempty(obj.full_filename)
                    obj.full_filename = 'in_mem';
                end
                obj.tmp_file_holder_ = TmpFileHandler(obj.full_filename);

                obj.write_handle_ = sqw_fopen(obj.tmp_file_holder_.file_name, 'wb+');
            end
            obj.pix_written = 0;
        end

        function obj = format_dump_data(obj, data)
            if ~obj.has_open_file_handle
                error('HORACE:PixelDataFileBacked:runtime_error', ...
                    'Cannot dump data, object does not have open filehandle')
            end

            if isa(obj.write_handle_, 'sqw_file_interface')
                obj.write_handle_.put_raw_pix(data, obj.pix_written+1);
            else
                fwrite(obj.write_handle_, single(data), 'single');
            end
            obj.pix_written = obj.pix_written + size(data, 2);
        end

        function obj = finish_dump(obj)
            if ~obj.has_open_file_handle
                error('HORACE:PixelDataFileBacked:runtime_error', ...
                    'Cannot finish dump writing, object does not have open filehandle')
            end

            obj.num_pixels_ = obj.pix_written;

            if isa(obj.write_handle_, 'sqw_file_interface')
                obj.full_filename = obj.write_handle_.full_filename;
                obj.write_handle_ = obj.write_handle_.put_pix_metadata(obj);
                % Force pixel update
                obj.write_handle_ = obj.write_handle_.put_num_pixels(obj.num_pixels);

                obj = obj.init_from_file_accessor_(obj.write_handle_, false, true);
                obj.write_handle_.delete();
                obj.write_handle_ = [];

            else
                fclose(obj.write_handle_);
                if obj.num_pixels_ == 0
                    obj = PixelDataMemory();
                    return;
                end

                obj.write_handle_ = [];
                obj.f_accessor_ = [];
                obj.offset_ = 0;
                obj.full_filename = obj.tmp_file_holder_.file_name;
                obj.f_accessor_ = memmapfile(obj.full_filename, ...
                    'format', obj.get_memmap_format(), ...
                    'Repeat', 1, ...
                    'Writable', true, ...
                    'offset', obj.offset_);
            end
        end

        function format = get_memmap_format(obj, tail)
            if isempty(obj.f_accessor_) || ~isa(obj.f_accessor_,'memmapfile')
                if nargin == 1
                    tail = 0;
                end
                data_size = double([PixelDataBase.DEFAULT_NUM_PIX_FIELDS, obj.num_pixels_]);
                if tail>0
                    format = {'single',data_size,'data';'uint8',double(tail),'tail'};
                else
                    format = {'single',data_size,'data'};
                end
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
            pix_copy.page_num = 1;
        end
    end
    %======================================================================
    methods(Static)
        % apply page operation(s) to the object with File-backed pixels
        sqw_out = apply_c(sqw_in,page_op);
        %
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

            if isempty(varargin)
                obj = PixelDataFileBacked();
                return;
            elseif numel(varargin) == 1
                if isa(varargin{1}, 'PixelDataMemory')
                    obj = PixelDataFileBacked(varargin{1});
                elseif isa(varargin{1}, 'PixelDataFileBacked')
                    obj = varargin{1};
                end
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
            obj.data_range_ = PixelDataBase.EMPTY_RANGE;
            for i = 1:numel(varargin)
                curr_pix = varargin{i};
                num_pages= curr_pix.num_pages;
                for page = 1:num_pages
                    curr_pix.page_num = i;
                    data = curr_pix.data;
                    obj = obj.format_dump_data(data);
                    obj.data_range_ = ...
                        obj.pix_minmax_ranges(data, obj.data_range_);
                    start_idx = start_idx + size(data,2);
                end
            end
            obj = obj.finish_dump();
        end
    end

    %======================================================================
    % implementation of PixelDataBase abstract protected interface
    methods (Access = protected)
        function pix_data = get_raw_pix_data(obj,row_pix_idx,col_pix_idx)
            % Overloaded part of get_raw_pix operation. 
            % 
            % return unmodified pixel data according to the input indexes
            % provided.
            % Inputs:
            % obj         -- initialized pixel data memory object
            % row_pix_idx -- indixes of pixels to return
            % col_pix_idx -- if not empty, the indices of the pixel field
            %                to return, if empty, all pixels field
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
