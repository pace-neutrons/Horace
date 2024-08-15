classdef (InferiorClasses = {?DnDBase,?IX_dataset,?sigvar},Abstract) ...
        PixelDataBase < data_op_interface & serializable
    % PixelDataBase provides an abstract base-class interface for pixel data objects
    %
    %   This class provides getters and setters for each data column in an SQW
    %   pixel array. Along with a creation mechanism for constructing the PixelData
    %   subclasses
    %
    %   Construct this class with an 9 x N array, a file path to an SQW object or
    %   an instance of sqw_binfile_common.
    %
    %   >> pix_data = PixelDataBase.create(init, mem_alloc, upgrade, file_backed)
    %   >> pix_data = PixelDataBase.create(data);
    %   >> pix_data = PixelDataBase.create('/path/to/sqw.sqw');
    %   >> pix_data = PixelDataBase.create(faccess_obj);
    %
    %   Constructing an object using PixelDataBase.create will create either a
    %   PixelDataMemory or PixelDataFileBacked depending on whether the resulting
    %   object would fit into `mem_chunk_size`. It is possible, though inadvisable
    %   To override this via the `mem_alloc` argument, or force the desired type by
    %   calling the appropriate object constructor or passing file_backed (true|false).
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
    % Properties:
    %  full_filename   - full name of the file this pixels are based on or
    %                    were loaded from
    %   num_pixels     - The number of pixels in the data block.
    %   u1, u2, u3     - The 1st, 2nd and 3rd dimensions of the Crystal
    %                    Cartesian coordinates in projection axes, units are per Angstroms (1 x n arrays)
    %   dE             - The energy transfer value for each pixel in meV (1 x n array)
    %   coordinates    - The coords in projection axes of the pixel data [u1, u2, u3, dE] (4 x n array)
    %   q_coordinates  - The spatial coords in projection axes of the pixel data [u1, u2, u3] (3 x n array)
    %   run_idx        - The run index the pixel originated from (1 x n array)
    %   detector_idx   - The detector group number in the detector listing for the pixels (1 x n array)
    %   energy_idx     - The energy bin numbers (1 x n array)
    %   signal         - The signal array (1 x n array).
    %   variance       - The variance on the signal array (variance i.e. error bar squared) (1 x n array)
    %
    %   data_range     - [2x9] array of the range of pixels arrays above
    %
    %   data           - The whole array of  pixel data - usage of this
    %                    attribute is discouraged, the structure of the
    %                    return value is not guaranteed.
    %   page_size      - The number of pixels in the currently loaded page.
    %
    %======================================================================
    properties (Dependent)
        full_filename; % full name of the file this pixels are based on or
        %                were loaded from
        num_pixels;         % The number of pixels class contains
        %------------------------------------------------------------------
        u1; % The 1st dimension of the Crystal Cartesian orientation (1 x n array) [A^-1]
        u2; % The 2nd dimension of the Crystal Cartesian orientation (1 x n array) [A^-1]
        u3; % The 3rd dimension of the Crystal Cartesian orientation (1 x n array) [A^-1]
        dE; % The array of energy deltas of the pixels (1 x n array) [meV]

        run_idx;     % The run index the pixel originated from (1 x n array)
        detector_idx; % The detector group number in the detector listing
        %             % for the pixels (1 x n array)
        energy_idx;   % The energy bin numbers (1 x n array)

        signal;   % The signal array (1 x n array)
        variance; % The variance on the signal array
        %  (variance i.e. error bar squared) (1 x n array)


        pix_range; % The range of pixels coordinates in Crystal Cartesian
        % coordinate system. [2x4] array of [min;max] values of pixels
        % coordinates field. If data are file-based and you are setting
        % pixels coordinates, this value may get invalid, as the range
        % never shrinks.
        data_range  % the range of pix data. 2x9 array of [min;max] values
        % of pixels data field

        data; % The full pixel data block. Usage of this attribute exposes
        % current pixels layout, so when the pixels layout changes in a
        % future, the code using this attribute will change too. So, the usage
        % of this attribute is discouraged as the structure of the return
        % value is not guaranteed in a future.

        page_num    % current page number
        num_pages   % number of pages in the whole data file
        page_size;  % The number of pixels that can fit in one page of data
        read_only   % Specify if you can modify the data of your pixels
        %
        is_misaligned % true if pixel data are not in Crystal Cartesian and
        %              and true Crystal Cartesian is obtained by
        %              multiplying data by the alignment matrix
        alignment_matr % matrix used for multiplying misaligned pixel data
        %               to convert their coordinates into CrystalCartesian
        %               coordinate system. If pixels are not misaligned,
        %               the matrix is eye(3);
    end
    properties(Dependent,Hidden)
        % hidden not to pollute interface
        q_coordinates; % The spatial dimensions of the Crystal Cartesian
        %              % orientation (3 x npix array)
        coordinates;   % The coordinates of the pixels in the projection axes, i.e.: u1,
        %              % u2, u3 and dE (4 x npix array)
        sig_var        % return [2 x npix] array of signal and variance
        all_indexes;   % array all run indexes ([3 x npix] array of indexes)
        all_experiment % [5xnpi] array of all data obtained in experiment, excluding
        % q-dE, which are calculated from indexes and detector positions

        % if false, converts all pixel data loaded from disk into double
        % precision
        keep_precision
        % Property returns size of a pixel in bytes
        pix_byte_size
    end

    properties(Access=protected)
        PIXEL_BLOCK_COLS_ = PixelDataBase.DEFAULT_NUM_PIX_FIELDS;
        data_range_ = PixelDataBase.EMPTY_RANGE; % range of all other variables (signal, error, indexes)
        full_filename_ = '';
        is_misaligned_ = false;
        alignment_matr_ = eye(3);
        old_file_format_ = false;
        unique_run_id_ = [];
        % If true, do not convert data loaded from disk into double at
        % loading
        keep_precision_  = false;
    end

    properties(Dependent,Hidden)
        % TWO PROPERTIES USED IN SERIALIATION:
        % Their appearance this way is caused by need to access to pixel
        % data array from third party applications
        %
        % The property contains the pixel data layout in
        % memory or on disk and all additional properties describing
        % pix array, like its size, shape, alignment, etc
        metadata;
        % the property contains or describes the pixel data array itself.
        % Contains if the array fits memory or describes it if the only
        % possible location of this array is disk.
        data_wrap;
        %------------------------------------------------------------------
        % size of the pixel chunk to load in memory for further processing
        % in filebacked operations
        default_page_size;

        % The property returns page of data equivalent to data if PixelData
        % are in Crystal Cartesian coordinate system or page of
        % raw data (not multiplied by alignment matrix) if pixels
        % are misaligned.
        raw_data;

        % Property informing that data are obtained from old file format,
        % missing some substantial information. File operations may
        % process these files differently, recalculating some additional
        % parameters during operation
        old_file_format;
        % list of unique pixel ID-s present in pixels. Used to help loading
        % old data
        unique_run_id;
        % True if the object is filebacked and build on temporary file
        is_tmp_obj;
    end

    properties (Constant,Hidden)
        DEFAULT_NUM_PIX_FIELDS = 9;
        % the data range, an empty pixel class has
        EMPTY_RANGE = [inf(1,9);-inf(1,9)];
        EMPTY_PIXELS = zeros(9, 0);
        NO_INPUT_INDICES = -1;
        FIELD_INDEX_MAP = PixelDataBase.FIELD_INDEX_MAP_;
    end

    properties(Constant,Access=protected)
        COLS = {'u1', 'u2', 'u3', 'dE', ...
            'run_idx', ...
            'detector_idx', ...
            'energy_idx', ...
            'signal', ...
            'variance'};
        FIELD_INDEX_MAP_ = containers.Map(...
            {'u1', 'u2', 'u3', 'dE', ...
            'coordinates', ...
            'q_coordinates', ...
            'run_idx', ...
            'detector_idx', ...
            'energy_idx', ...
            'signal', ...
            'variance',...
            'sig_var',...
            'all_indexes',...
            'all_experiment',...
            'all'}, ...
            {1, 2, 3, 4, 1:4, 1:3, 5, 6, 7, 8, 9,[8,9],[5,6,7],5:9,1:9});
    end

    methods(Static,Hidden)
        function range = EMPTY_RANGE_()
            range = PixelDataBase.EMPTY_RANGE(:,1:4);
        end

    end

    methods (Static)
        out_obj = cat(varargin);
        function isfb = do_filebacked(num_pixels, scale_fac)
            % function defines default rule to make pixels filebased or memory
            % based.
            if nargin<2
                scale_fac = [];
            end
            isfb = do_filebacked_(num_pixels, scale_fac);
        end
        function [filename,move_to_orig] = build_op_filename(original_fn,target_fn)
            % Build filename - target of an operation.
            %
            % When an operation performed on filebacked object, its temporary
            % results are stored in a temporary file. The name of this file
            % is build according to the rules defined here. See PageOpBase
            % for more information about operations.

            % Inputs:
            % original_fn -- name of the original file-source of the
            %                operation
            % target_fn   -- optional name of the file to save data
            %
            % Returns:
            % filename     -- target filename for operation.
            % move_to_orig -- true, if original filename was equal to
            %                 target filename and we need to move resulting
            %                 file to the initial location as the result of
            %                 operation. False otherwise.
            [filename,move_to_orig] = build_op_filename_(original_fn,target_fn);
        end

        function obj = create(varargin)
            % Factory to construct a PixelData object from the given data. Default
            % construction initialises the underlying data as an empty (9 x 0)
            % array.
            %
            %   >> obj = PixelDataBase.create(ones(9, 200))
            %
            %   >> obj = PixelDataBase.create(200)  % initialise 200 pixels with underlying data set to zero
            %
            %   >> obj = PixelDataBase.create(full_filename)  % initialise pixel data from an sqw file
            %
            %   >> obj = PixelDataBase.create(faccess_reader)  % initialise pixel data from an sqw file reader
            %
            %
            % Input:
            % ------
            %   init    A 9 x n matrix, where each row corresponds to a pixel and
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
            %  init    An integer specifying the desired number of pixels. The underlying
            %         data will be filled with zeros.
            %
            %  init    A path to an SQW file.
            %
            %  init    An instance of an sqw_binfile_common file reader.
            % Options:
            %  '-filebacked' -- if present, request filebacked data (does
            %                   not work currently work with array of data)
            %  '-upgrade'    -- if present, alow write access to filebased
            %  '-writable'      data (properties are synonymous)
            %  '-norange'    -- if present, do not calculate the range of
            %                   pix data if this range is missing. Should
            %                   be selected during file-format upgrade, as
            %                   the range calculations are performed in
            %                   create procedure.
            obj = create_(varargin{:});
        end

        function npix = bytes2pix(bytes)
            npix = bytes / sqw_binfile_common.FILE_PIX_SIZE;
        end

        function loc_range = pix_minmax_ranges(data, current)
            % Compute the minmax ranges in data in the appropriate format for
            % PixelData objects
            loc_range = min_max(data)';
            if exist('current', 'var')
                loc_range = minmax_ranges(current,loc_range);
            end
        end
        function idx = field_index(fld_name)
            % Return field indexes as function of the field name or
            % cellarray of field names
            %
            % Input:
            % ------
            % fields    -- A cellstr of field names to validate.
            %
            % Output:
            % indices   -- the indices corresponding to the fields
            %

            if iscell(fld_name)
                idx=cellfun(@(x)PixelDataBase.FIELD_INDEX_MAP_(x),fld_name, ...
                    'UniformOutput',false);
                idx = [idx{:}];
            elseif isnumeric(fld_name)
                idx = fld_name(:)';
            elseif istext(fld_name)
                idx = PixelDataBase.FIELD_INDEX_MAP_(fld_name);
            else
                error('HORACE:PixelDataBase:invalid_argument',...
                    ['Method accepts the name of the pixel field, array of field indices or cellarray of fields.\n' ...
                    'Actually input class is: %s'],class(fld_name));
            end
        end
        function format = get_memmap_format(num_pixels, tail)
            if nargin == 1
                tail = 0;
            end
            data_size = double([PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pixels]);
            if tail>0
                format = {'single',data_size,'data';'uint8',double(tail),'tail'};
            else
                format = {'single',data_size,'data'};
            end
        end

    end
    %======================================================================
    %  ABSTRACT INTERFACE
    %======================================================================
    methods(Abstract)
        % --- Pixel operations ---
        pix_copy = copy(obj);

        data = get_raw_data(obj,varargin);
        pix  = set_raw_data(obj,pix);

        obj = recalc_data_range(obj,varargin);

        % return byte-size of single pixel
        sz = get_pix_byte_size(obj,keep_precision);
    end
    %======================================================================
    % File handling/migration.
    methods(Abstract)
        % close all open file handles to allow file movements to new
        % file/new location.
        obj = deactivate(obj)
        % reopen file previously closed by deactivate
        % operation, possibly using new file name
        [obj,varargout] = activate(obj,filename,varargin);

        obj = get_write_handle(obj, varargin)
        obj = store_page_data(obj,data_page)
        %
        obj = finish_dump(obj,page_op)
        %
        % Sets file, associated with object to be removed when obj gets out of scope
        obj =set_as_tmp_obj(obj,filename);
        % Paging:
        % pixel indices of the current page
        [pix_idx_start, pix_idx_end] = get_page_idx_(obj, varargin)
        % Reset the object to point to the first page of pixel data in the file
        % and clear the current cache
        obj = move_to_first_page(obj)
    end
    %======================================================================
    methods(Abstract,Access=protected)
        % Main part of get.num_pixels accessor
        num_pix = get_num_pixels(obj);
        ro      = get_read_only(obj)
        %------------------------------------------------------------------
        prp = get_prop(obj, ind);
        obj = set_prop(obj, ind, val);

        % main part of get.data accessor
        data  = get_data(obj);
        % common interface to getting pixel data. Class dependent
        % implementation
        data = get_raw_pix_data(obj,row_idx,col_idx);

        % setters/getters for serializable interface properties
        obj = set_data_wrap(obj,val);
        %------------------------------------------------------------------
        % set non-unary alignment matrix and recalculate or invalidate pix averages
        % part of alignment_mart setter
        obj = set_alignment_matrix(obj,val);
        %------------------------------------------------------------------
        % paging/IO operations
        page_size = get_page_size(obj);
        np  = get_page_num(obj);
        obj = set_page_num(obj,val);
        np  = get_num_pages(obj);

        is = get_is_tmp_obj(obj);
    end
    %======================================================================
    methods(Abstract,Static)
        obj_out = apply_op(obj_in,page_op);
    end
    %======================================================================
    % the same interface on FB and MB files
    methods
        function cnt = get_field_count(obj, field)
            cnt = numel(obj.FIELD_INDEX_MAP_(field));
        end

        pix_out = get_pix_in_ranges(obj, abs_indices_starts, block_sizes,...
            recalculate_pix_ranges,keep_precision);

        [ok, mess] = equal_to_tol(obj, other_pix, varargin);

        function obj = invalidate_range(obj,fld)
            % set the data range to inverse values
            % to allow
            if nargin == 1 % invalidate the whole range
                idx = obj.FIELD_INDEX_MAP_('all');
            else
                idx = obj.FIELD_INDEX_MAP_(fld);
            end
            obj.data_range_(:,idx) = obj.EMPTY_RANGE(:,idx);
        end
        %
        function is = is_range_valid(obj,fld)
            % check if the range for the appropriate fields, provided as
            % input is valid, i.e. not equal to empty range;
            if nargin == 1 % check the whole range
                idx = obj.FIELD_INDEX_MAP_('all');
            elseif iscell(fld)
                idx = cellfun(@(fl)obj.FIELD_INDEX_MAP_(fl),fld);
            else
                idx = obj.FIELD_INDEX_MAP_(fld);
            end
            invalid = obj.data_range_(:,idx) == obj.EMPTY_RANGE(:,idx);
            is = ~any(invalid(:));
        end
        %
        function obj=set_data_range(obj,data_range)
            % Function allows to set the pixels range (min/max values of
            % pixels coordinates)
            %
            % WARNING: Use with caution!!! As this is performance function,
            % no checks that the set range is the
            % correct range for pixels, hold by the class are
            % performed, while subsequent algorithms may rely on pix range
            % to be correct. A out-of memory assignment can occur during
            % rebinning if the range is smaller, then the actual range.
            %
            % Necessary to set up the pixel range when filebased
            % pixels are modified by algorithm and correct range
            % calculations are expensive
            %
            if ~isequal(size(data_range),[2,9])
                error('HORACE:PixelDataBase:invalid_argument',...
                    'data_range should be [2x9] array of data ranges');
            end
            obj.data_range_ = data_range;
        end
    end
    %======================================================================
    % Property GETTERS/SETTERS
    methods
        % DATA accessors:
        function data = get.data(obj)
            data = get_data(obj,get_page_num(obj));
        end
        function obj=set.data(obj, pixel_data)
            obj=set_raw_data(obj, pixel_data);
            obj = obj.recalc_data_range();
        end

        function u1 = get.u1(obj)
            u1 = obj.get_prop('u1');
        end
        function obj= set.u1(obj, val)
            obj= obj.set_prop('u1', val);
        end
        %
        function u2 = get.u2(obj)
            u2 = obj.get_prop('u2');
        end
        function obj= set.u2(obj, val)
            obj= obj.set_prop('u2', val);
        end
        %
        function u3 = get.u3(obj)
            u3 = obj.get_prop('u3');
        end
        function obj= set.u3(obj, val)
            obj= obj.set_prop('u3', val);
        end
        %
        function dE = get.dE(obj)
            dE = obj.get_prop('dE');
        end
        function obj= set.dE(obj, val)
            obj= obj.set_prop('dE', val);
        end
        %
        function q_coordinates = get.q_coordinates(obj)
            q_coordinates = obj.get_prop('q_coordinates');
        end
        function obj= set.q_coordinates(obj, val)
            obj= obj.set_prop('q_coordinates', val);
        end
        %
        function coordinates = get.coordinates(obj)
            coordinates = obj.get_prop('coordinates');
        end
        function obj= set.coordinates(obj, val)
            obj= obj.set_prop('coordinates', val);
        end
        %
        function run_idx = get.run_idx(obj)
            run_idx = obj.get_prop('run_idx');
        end
        function obj= set.run_idx(obj, val)
            obj=obj.set_prop('run_idx', val);
        end
        %
        function detector_idx = get.detector_idx(obj)
            detector_idx = obj.get_prop('detector_idx');
        end
        function obj= set.detector_idx(obj, val)
            obj= obj.set_prop('detector_idx', val);
        end
        %
        function energy_idx = get.energy_idx(obj)
            energy_idx = obj.get_prop('energy_idx');
        end
        function obj= set.energy_idx(obj, val)
            obj=obj.set_prop('energy_idx', val);
        end
        %
        function signal = get.signal(obj)
            signal = obj.get_prop('signal');
        end
        function obj= set.signal(obj, val)
            obj=obj.set_prop('signal', val);
        end
        %
        function variance = get.variance(obj)
            variance = obj.get_prop('variance');
        end
        function obj= set.variance(obj, val)
            obj=obj.set_prop('variance', val);
        end
        %
        function sig_var = get.sig_var(obj)
            sig_var  = obj.get_prop('sig_var');
        end
        function obj= set.sig_var(obj, val)
            obj=obj.set_prop('sig_var', val);
        end
        %
        function idx = get.all_indexes(obj)
            idx = obj.get_prop('all_indexes');
        end
        function obj = set.all_indexes(obj,val)
            obj=obj.set_prop('all_indexes', val);
        end

        %
        function expr = get.all_experiment(obj)
            expr  = obj.get_prop('all_experiment');
        end
        function obj= set.all_experiment(obj, val)
            obj=obj.set_prop('all_experiment', val);
        end
        %------------------------------------------------------------------
        function is = get.is_misaligned(obj)
            is = obj.is_misaligned_;
        end
        function obj = clear_alignment(obj)
            % Clears alignment.
            %
            % If alignment changes, invalidates object integrity,
            % (data_ranges need recalculation)
            % so should be used as part of algorithms only.
            obj.is_misaligned_ = false;
            obj.alignment_matr_ = eye(3);
        end
        function matr = get.alignment_matr(obj)
            matr = obj.alignment_matr_;
        end
        function obj = set.alignment_matr(obj,val)
            obj = set_alignment_matrix(obj,val);
        end
        %
        function data = get.raw_data(obj)
            data = get_raw_data(obj);
        end
        %------------------------------------------------------------------
        function range = get.pix_range(obj)
            range = get_data_range(obj,1:4);
        end

        function obj = set.pix_range(obj,range)
            obj = set_pix_range(obj,range);
        end

        function obj = set_pix_range(obj,range)
            if ~isnumeric(range) || ~isequal(size(range),[2,4])
                error('HORACE:PixelDataBase:invalid_argument',...
                    'pixel range have to be array of size 2x4')
            end
            obj.data_range_(:,1:4) = range;
        end

        function srange = get.data_range(obj)
            srange = get_data_range(obj);
        end

        function obj = set.data_range(obj,val)
            obj = obj.set_data_range(val);
        end

        function ps = get.default_page_size(~)
            ps = config_store.instance().get_value('hor_config', 'mem_chunk_size');
        end

        function obj = set.full_filename(obj, val)
            obj = set_full_filename(obj,val);
        end

        function val = get.full_filename(obj)
            val = get_full_filename(obj);
        end

        function num_pix = get.num_pixels(obj)
            num_pix = get_num_pixels(obj);
        end

        %------------------------------------------------------------------
        % data/metadata construction
        function val = get.data_wrap(obj)
            val = get_data_wrap(obj);
        end

        function obj = set.data_wrap(obj,val)
            obj = set_data_wrap(obj,val);
            if obj.do_check_combo_arg
                obj = obj.check_combo_arg();
            end
        end

        function val = get.metadata(obj)
            ws = warning('off','HORACE:invalid_data_range');
            val = pix_metadata(obj);
            warning(ws);
        end

        function obj = set.metadata(obj,val)
            obj = set_metadata(obj,val);
        end

        %------------------------------------------------------------------
        % paging, read-only access
        function page_size = get.page_size(obj)
            page_size = get_page_size(obj);
        end

        function pn = get.page_num(obj)
            pn = get_page_num(obj);
        end

        function obj = set.page_num(obj,val)
            obj = set_page_num(obj,val);
        end

        function np = get.num_pages(obj)
            np = get_num_pages(obj);
        end

        function ro = get.read_only(obj)
            ro = get_read_only(obj);
        end
        %
        function is = get.old_file_format(obj)
            is = obj.old_file_format_;
        end
        function obj = set.old_file_format(obj,val)
            obj.old_file_format_ = logical(val);
        end
        %
        function ids = get.unique_run_id(obj)
            % property helps in loading pixels from old file format
            %
            ids = obj.unique_run_id_;
        end
        %
        function do = get.keep_precision(obj)
            do = obj.keep_precision_;
        end
        function obj = set.keep_precision(obj,val)
            obj.keep_precision_ = logical(val);
        end
        %
        function is = get.is_tmp_obj(obj)
            is = get_is_tmp_obj(obj);
        end
        function sz = get.pix_byte_size(obj)
            % In a future it may be overloaded to account for various types
            % of pixel data but we can not yet give clear specification for
            % that.
            sz = get_pix_byte_size(obj);
        end
    end
    %----------------------------------------------------------------------
    methods
        % return set of pixels, defined by its indexes
        pix_out = get_pixels(obj, abs_pix_indices,varargin);
        %==================================================================
        % These methods are historically present on pixels and were modifying
        % sqw object image indirectly. Now they are reimplemented on sqw
        % object using apply_op, and left here for historical reasons and for
        % the case, when one may want to use them on pixels only (testing?).
        pix_out = mask(obj, mask_array, npix);
        obj     = finalize_alignment(obj,filename);
        pix_out = noisify(obj, varargin);
        pix_out = apply(obj, func_handle, args, data, compute_variance);

        pix_out = do_unary_op(obj, unary_op)
        pix_out = do_binary_op(obj, operand, binary_op, varargin);

        %
        %------------------------------------------------------------------
        % Helpers for page_op and data_op_interface. Work with data in
        % memory regarless of file/memory based class
        function sz = sigvar_size(~)
            % sigvar_size is the size of image, so pixels only are always in
            % d0d image (compartible with any image).
            sz = [1,1];
        end
        function sg = sigvar(obj)
            % returns only single page data
            sg = sigvar(obj.signal,obj.variance);
        end
        %------------------------------------------------------------------
        function [mean_signal, mean_variance,signal_msd] = compute_bin_data(obj, npix,pix_idx)
            % Calculate signal/error bin averages for block of pixel data
            % defined by npix.
            % Inputs:
            % obj     -- initialized instance of the PixelData object
            % npix    -- array of npix, used to arrange pixels. If pix_idx
            %            are missing, sum(npix(:)) == obj.num_pixels should
            %            hold.
            % Optional:
            % pix_idx -- if present, defines the indexes of pixels, which
            %            are arranged according to npix.
            %
            if nargin <3
                pix_idx = [];
            end
            calc_signal_msd = nargout == 3;
            calc_variance   = nargout > 1;
            [mean_signal, mean_variance,signal_msd] = ...
                compute_bin_data_(obj, npix,pix_idx,calc_variance,calc_signal_msd);
        end
    end
    %======================================================================
    % Overloadable protected getters/setters for properties
    methods(Access=protected)        %
        function val = check_set_prop(obj,fld,val)
            % check input parameters of set_property function
            if ~isnumeric(val)
                error('HORACE:PixelDataBase:invalid_argument', ...
                    'Value for property %s have to be numeric',fld);
            end
            block_size = [obj.get_field_count(fld), obj.page_size];
            if isscalar(val)
                return;
            elseif ~isequal(numel(val),prod(block_size) )
                error('HORACE:PixelDataBase:invalid_argument', ...
                    '%s value must be scalar or [%d %d] numeric array. Received: %s %s', ...
                    fld, block_size(1), block_size(2), mat2str(size(val)), class(val))
            end
            val = reshape(val,block_size);
        end

        function obj = set_full_filename(obj,val)
            % main part of file path setter. Need checks/modification
            if ~istext(val)
                error('HORACE:PixelDataBase:invalid_argument',...
                    'full_filename must be a string. Received: %s', ...
                    class(val));
            end
            obj.full_filename_ = val;
        end
        %
        function obj =  set_metadata(obj,val)
            % main part of set from metadata setter
            if ~isa(val,'pix_metadata')
                error('HORACE:PixelDataBase:invalid_argument',...
                    'metadata can only be set to instance of pix_metadata class. Provided class: %s', ...
                    class(val))
            end

            obj.full_filename_   = val.full_filename;
            obj.data_range_      = val.data_range;
            if val.is_misaligned
                obj.alignment_matr_ = val.alignment_matr;
                obj.is_misaligned_  = true;
            end
            if obj.do_check_combo_arg
                obj = obj.check_combo_arg();
            end
        end
        %
        function full_filename = get_full_filename(obj)
            full_filename = obj.full_filename_;
        end
        %
        function val = get_data_wrap(obj)
            % main part of pix_data_wrap getter which allows overload for
            % different children
            val = pix_data(obj);
        end
        %
        function data_range = get_data_range(obj,field_idx)
            % data range getter
            %
            % if field_idx provided, return ranges for the pixel fields with
            % indexes provided.
            %
            if nargin == 1
                data_range = obj.data_range_;
            else
                data_range = obj.data_range_(:,field_idx);
            end
        end
    end
    %======================================================================
    % Helper methods.
    methods(Access=protected)
        function [obj,alignment_changed] = set_alignment(obj,val,pix_treatment_function)
            % set non-unary alignment matrix and recalculate or invalidate
            % pix averages.
            % Part of alignment_mart setter
            % Inputs:
            % obj    -- initial object
            % val    -- 3x3 alignment matrix or empty value if matrix
            %           invalidation is requested
            % pix_treatment_function
            %        -- the function to apply to the PixelDataBase object
            %           after aligment changes e.g. for recalculation or
            %            invalidation of pixel averages.
            [obj,alignment_changed] = set_alignment_matr_(obj,val,pix_treatment_function);
        end
        %------------------------------------------------------------------
        function [abs_pix_indices,pix_col_idx,ignore_range,raw_data,keep_precision,align] = ...
                parse_get_pix_args(obj,accepts_logical,varargin)
            % process input of get_pix method and return input parameters
            % in the standard form.

            [abs_pix_indices,pix_col_idx,ignore_range,raw_data,keep_precision,align] = ...
                parse_get_pix_args_(obj,accepts_logical,varargin{:});
        end
        %
        function pix_out = pack_get_pix_result(obj,pix_data,ignore_range,raw_data,keep_precision,align)
            % pack output of get_pixels method depending on various
            % get_pixels input options
            % Input:
            % obj          -- original PixelDataBase object
            % pix_data     -- array of raw pixel data retrieved by
            %                 get_pixel method core code
            % ignore_range -- if true, do not calculate pixels range
            % raw_data     -- if true, do not wrap pix_data into
            %                 PixelDataBase class
            % keep_precision
            %              -- if true, keep original pixel precision
            %                 intact. Do not make it double
            % align        -- if true and data are misaligned, apply
            %                 alignment matrix and re-align the data
            %
            pix_out = pack_get_pix_result_(obj,pix_data, ...
                ignore_range,raw_data,keep_precision,align);
        end
        %
        function [obj,unique_idx] = calc_page_range(obj,field_name)
            % Recalculate and set appropriate range of pixel coordinates.
            % The coordinates are defined by the selected field
            %
            % Sets up the property page_range defining the range of block
            % of pixels changed at current iteration.

            %NOTE:  This range calculations are incorrect unless
            %       performed in a loop over all pix pages where initial
            %       range is set to empty!
            %
            ind = obj.field_index(field_name);

            obj.data_range_(:,ind) = obj.pix_minmax_ranges(obj.data(ind,:), ...
                obj.data_range_(:,ind));
            if nargout > 1
                unique_idx = unique(obj.run_idx);
            end
        end
        %------------------------------------------------------------------
        %Operations
        w = unary_op_manager (w1, op_function_handle);
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    properties(Constant, Access=private)
        % list of filenames to save on hdd to be able to recover
        % all substantial parts of appropriate sqw file
        % Does not properly support filebased data. The decision is not to
        % save filebased data into mat files
        %fields_to_save_ = {'data','num_pixels','pix_range','file_path'};

        % ORDERF OF fields is important! data wrap defines data, and
        % metadata contains data_range. If data_range have been set
        % directly, data may recalculate range, and metadata would override
        % it.
        fields_to_save_ = {'data_wrap', 'metadata'};
    end

    methods(Static)
        function obj = loadobj(S,varargin)
            % Generic method, used by particular class loadobj method
            % to recover any serializable class
            %   >> obj = loadobj(S)
            %
            % Input:
            % ------
            %   S       Either (1) an object of the class, or (2) a structure
            %           or structure array previously obtained by saveobj
            %           method
            %  class_instance -- the instance of a serializable class to
            %          recover from input S
            %
            % Output:
            % -------
            %   obj     Either (1) the object passed without change, or (2) an
            %           object (or object array) created from the input structure
            %           or structure array)
            if isfield(S,'data_')
                S.data = S.data_;
            end

            if isfield(S,'raw_data_')
                S.data = S.raw_data_;
            end

            if isfield(S,'data') && istext(S.data)
                obj = PixelDataFileBacked();
            else
                obj = PixelDataMemory();
            end
            obj = loadobj@serializable(S,obj);
        end

    end

    methods
        function  ver  = classVersion(~)
            % serializable fields version
            ver = 2;
        end
        function flds = saveableFields(~)
            flds = PixelDataBase.fields_to_save_;
        end
    end

    methods(Access=protected)
        function obj = from_old_struct(obj,inputs)
            % Restore object from the old structure, which describes the
            % previous version of the object.
            %
            % The method is called by loadobj in the case if the input
            % structure does not contain version or the version, stored
            % in the structure does not correspond to the current version
            %
            % By default, this function interfaces the default from_bare_struct
            % method, but when the old structure substantially differs from
            % the modern structure, this method needs the specific overloading
            % to allow loadobj to recover new structure from an old structure.
            %
            if isfield(inputs,'data_')
                % build from old PixelData stored in the file
                obj.data = inputs.data_;

            elseif isfield(inputs,'data')
                obj.data = inputs.data;

                if isfield(inputs,'file_path_')
                    obj.full_filename = inputs.file_path_;

                elseif isfield(inputs,'file_path')
                    obj.full_filename = inputs.file_path;
                end

            elseif isfield(inputs,'raw_data_')
                obj.data = inputs.raw_data_;

            elseif isfield(inputs,'array_dat')
                obj = obj.from_bare_struct(inputs.array_dat);

            else
                obj = obj.from_bare_struct(inputs);
            end
        end
    end
end
