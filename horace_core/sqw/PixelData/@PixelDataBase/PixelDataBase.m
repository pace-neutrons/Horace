classdef (Abstract) PixelDataBase < serializable
    % PixelDataBase provides an abstract base-class interface for pixel data objects
    %
    %   This class provides etetters and setters for each data column in an SQW
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
        PIXEL_BLOCK_COLS_ = PixelDataBase.DEFAULT_NUM_PIX_FIELDS;
        data_ = zeros(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 0);  % the underlying data cached in the object
        data_range_ = PixelDataBase.EMPTY_RANGE; % range of all other variables (signal, error, indexes)
        full_filename_ = '';
    end
    properties(Dependent,Hidden)
        DEFAULT_PAGE_SIZE;
        % The property, which describes the pixel data layout on disk or in
        % memory and all additional properties describing pix array
        metadata;
        data_wrap;
    end

    properties (Constant,Hidden)
        DEFAULT_NUM_PIX_FIELDS = 9;
        % the data range, an empty pixel class has
        EMPTY_RANGE= [inf,inf,inf,inf,inf,inf,inf,inf,inf;...
            -inf,-inf,-inf,-inf,-inf,-inf,-inf,-inf,-inf];
    end

    properties(Constant,Access=protected)
        FIELD_INDEX_MAP_ = containers.Map(...
            {'u1', 'u2', 'u3', 'dE', ...
            'coordinates', ...
            'q_coordinates', ...
            'run_idx', ...
            'detector_idx', ...
            'energy_idx', ...
            'signal', ...
            'variance',...
            'all'}, ...
            {1, 2, 3, 4, 1:4, 1:3, 5, 6, 7, 8, 9,1:9});
    end

    properties (Dependent)
        full_filename;
        u1; % The 1st dimension of the Crystal Cartesian orientation (1 x n array) [A^-1]
        u2; % The 2nd dimension of the Crystal Cartesian orientation (1 x n array) [A^-1]
        u3; % The 3rd dimension of the Crystal Cartesian orientation (1 x n array) [A^-1]
        dE; % The array of energy deltas of the pixels (1 x n array) [meV]

        q_coordinates; % The spatial dimensions of the Crystal Cartesian
        %              % orientation (3 x n array)
        coordinates;   % The coordinates of the pixels in the projection axes, i.e.: u1,
        %              % u2, u3 and dE (4 x n array)

        run_idx; % The run index the pixel originated from (1 x n array)
        detector_idx; % The detector group number in the detector listing for the pixels (1 x n array)
        energy_idx;   % The energy bin numbers (1 x n array)

        signal;   % The signal array (1 x n array)
        variance; % The variance on the signal array
        %  (variance i.e. error bar squared) (1 x n array)
        num_pixels;         % The number of pixels in the data block

        pix_range; % The range of pixels coordinates in Crystal Cartesian
        % coordinate system. [2x4] array of [min;max] values of pixels
        % coordinates field. If data are file-based and you are setting
        % pixels coordinates, this value may get invalid, as the range
        % never shrinks.
        data_range  % the range of pix data. 2x9 array of [min;max] values
        % of pixels data field

        data; % The full raw pixel data block. Usage of this attribute exposes
        % current pixels layout, so when the pixels layout changes in a
        % future, the code using this attribute will change too. So, the usage
        % of this attribute is discouraged as the structure of the return
        % value is not guaranteed in a future.

        page_num    % current page number
        num_pages   % number of pages in the whole data file
        page_size;  % The number of pixels that can fit in one page of data
    end
    methods(Static,Hidden)
        function range = EMPTY_RANGE_()
            range = PixelDataBase.EMPTY_RANGE(:,1:4);
        end

    end

    methods (Static)
        function isfb = do_filebacked(num_pixels)
            % function defines the rule to make pixels filebased or memory
            % based
            mem_chunk_size = config_store.instance().get_value('hor_config','mem_chunk_size');
            % 3 should go to configuration too
            isfb = num_pixels > 3*mem_chunk_size;
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
            %  '-writable'      data
            %  '-norange'    -- if present, do not calculate the range of 
            %                   pix data if this range is missing. Should
            %                   be selected during file-format upgrade
            if nargin == 0
                obj = PixelDataMemory();
                return
            end
            [ok,mess,file_backed_requested,upgrade,writable,norange,argi] = parse_char_options(varargin, ...
                {'-filebacked','-upgrade','-writable','-norange'});
            if ~ok
                error('HORACE:PixelDataBase:invalid_argument',mess);
            end
            upgrade = upgrade||writable;
            if numel(argi) > 1 % build from metadata/data properties
                is_md = cellfun(@(x)isa(x,'pix_data'),argi);
                if any(is_md)
                    pxd = argi{is_md};
                    if ischar(pxd.data) || file_backed_requested
                        obj = PixelDataFileBacked(argi{:}, upgrade);
                    else
                        obj = PixelDataMemory(argi{:}, upgrade);
                    end
                else
                    error('HORACE:PixelDataBase:invalid_argument', ...
                        'Some input parameters of the PixelDataBase.create operation are not recoginized');
                end
                return;
            else
                init = argi{1};
            end

            % In memory construction
            if isstruct(init)
                obj = serializable.from_struct(init);
            elseif isa(init, 'PixelDataMemory')
                if file_backed_requested
                    obj = PixelDataFileBacked(init, upgrade);
                else
                    obj = PixelDataMemory(init);
                end
                % if the file exists we can create a file-backed instance
            elseif isa(init, 'PixelDataFileBacked')
                if file_backed_requested
                    obj = PixelDataFileBacked(init, upgrade);
                else
                    obj = PixelDataMemory(init);
                end

            elseif numel(init) == 1 && isnumeric(init) && floor(init) == init
                % input is an integer
                obj = PixelDataMemory(init);
            elseif isnumeric(init)
                % Input is data array
                obj = PixelDataMemory(init);
                % File-backed or loader construction
            elseif ischar(init) || isstring(init)|| isa(init, 'sqw_file_interface')
                if ischar(init) || isstring(init)
                    % input is a file path
                    init = sqw_formats_factory.instance().get_loader(init);
                end

                if PixelDataBase.do_filebacked(init.npixels) || file_backed_requested
                    obj = PixelDataFileBacked(init, upgrade);
                else
                    obj = PixelDataMemory(init);
                end
                undef = obj.data_range == obj.EMPTY_RANGE;
                if ~any(undef(:))
                    return;
                end
                % may be long operation. Should be able to indofm about
                % these intentions
                if ~norange
                    for i=1:numel(obj)
                        if obj.is_filebacked
                            warning('HORACE:old_file_format', ...
                                ['sqw file %s is written in old file format, which does not contain all necessary pixel averages.\n', ...
                                ' Update file format to the recent vesion to avoid recalculating these averages each time the file is loaded from disk'], ...
                                init.full_filename);
                        end
                        obj(i) = obj(i).recalc_data_range();
                    end
                end
            else
                error('HORACE:PixelDataBase:invalid_argument', ...
                    'Cannot create a PixelData object from class (%s)', ...
                    class(init))
            end
        end

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
            data_cell_array = cellfun(@(p) p.data, varargin, 'UniformOutput', false);
            data = cat(2, data_cell_array{:});
            obj = PixelDataBase.create(data);
        end

        function validate_mem_alloc(mem_alloc)
            if ~isnumeric(mem_alloc)
                error('HORACE:PixelData:invalid_argument', ...
                    ['Invalid mem_alloc. ''mem_alloc'' must be numeric, ' ...
                    'found class ''%s''.'], class(mem_alloc));
            elseif ~isscalar(mem_alloc)
                error('HORACE:PixelData:invalid_argument', ...
                    ['Invalid mem_alloc. ''mem_alloc'' must be a scalar, ' ...
                    'found size ''%s''.'], mat2str(size(mem_alloc)));
            end
            MIN_RECOMMENDED_PG_SIZE = 100e6;
            bytes_in_pix = sqw_binfile_common.FILE_PIX_SIZE;
            if mem_alloc < bytes_in_pix
                error('HORACE:PixelData:invalid_argument', ...
                    ['Error setting pixel page size. Cannot set page '...
                    'size less than %i bytes, as this is less than one pixel.'], ...
                    bytes_in_pix);
            elseif mem_alloc < MIN_RECOMMENDED_PG_SIZE
                warning('HORACE:PixelData:memory_allocation', ...
                    ['A pixel page size of less than 100MB is not ' ...
                    'recommended. This may degrade performance.']);
            end
        end

        function npix = bytes2pix(bytes)
            npix = bytes / sqw_binfile_common.FILE_PIX_SIZE;
        end

    end

    methods(Abstract)
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
        obj = recalc_data_range(obj);
        obj  =set_data(obj, data, fields, abs_pix_indices);


        has_more = has_more(obj);
        [obj,current_page_num, total_num_pages] = advance(obj, varargin);

    end
    methods(Abstract,Access=protected)
        % Maitn part of get.num_pixels accessor
        num_pix = get_num_pixels(obj);
        %
        prp = get_prop(obj, ind);
        obj = set_prop(obj, ind, val);
        %
        obj = reset_changed_coord_range(obj,range_type);
        % main part of get.data accessor
        data =  get_data_(obj)
        % setters/getters for serializable interface properties
        obj = set_data_wrap(obj,val);
        %
        % paging
        page_size = get_page_size(obj);
        np  = get_page_num(obj);
        obj = set_page_num(obj,val);
        np = get_num_pages(obj);
    end
    %======================================================================
    % GETTERS/SETTERS
    methods
        % DATA accessors:
        function data = get.data(obj)
            data = get_data_(obj);
        end
        function obj=set.data(obj, pixel_data)
            obj=set_data(obj, pixel_data);
        end
        %
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
            obj.set_prop('run_idx', val);
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
            obj.set_prop('energy_idx', val);
        end
        %
        function signal = get.signal(obj)
            signal = obj.get_prop('signal');
        end
        function obj= set.signal(obj, val)
            obj.set_prop('signal', val);
        end
        %
        function variance = get.variance(obj)
            variance = obj.get_prop('variance');
        end
        function obj= set.variance(obj, val)
            obj.set_prop('variance', val);
        end
        %------------------------------------------------------------------
        function range = get.pix_range(obj)
            range = obj.data_range_(:,1:4);
        end

        function srange = get.data_range(obj)
            srange = obj.data_range_;
        end
        function obj = set.data_range(obj,val)
            obj = obj.set_data_range(val);
        end

        function ps = get.DEFAULT_PAGE_SIZE(~)
            ps = config_store.instance().get_value('hor_config', 'mem_chunk_size');
        end
        %
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
        %
        function val = get.metadata(obj)
            val = pix_metadata(obj);
        end
        function obj = set.metadata(obj,val)
            obj = set_metadata(obj,val);
        end
        %------------------------------------------------------------------
        % paging
        function page_size = get.page_size(obj)
            page_size = get_page_size(obj);
            %page_size = size(obj.data_,2);
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
    end
    %--------------------------------------------------------------
    methods
        function obj=set_data_range(obj,data_range)
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
            if any(size(data_range) ~= [2,9])
                error('HORACE:PixelDataBase:invalid_argument',...
                    'data_range should be [2x9] array of data ranges');
            end
            obj.data_range_ = data_range;
        end

        function pix_copy = copy(obj)
            % Make an independent copy of this object
            %  This method simply constructs a new PixelData instance by calling
            %  the constructor with the input object as an argument. Because of
            %  this, any properties that need to be explicitly copied must be
            %  copied within this class' 'copy-constructor'.
            pix_copy = PixelDataBase.create(obj);
        end

        function obj = move_to_first_page(obj)
            % Reset the object to point to the first page of pixel data in the file
            % and clear the current cache
            %  This function does nothing if pixels are not file-backed.
            %
            obj.move_to_page(1);
        end

        function indices = check_pixel_fields_(obj, fields)
            %CHECK_PIXEL_FIELDS_ Check the given field names are valid pixel data fields
            % Raises error with ID 'HORACE:PIXELDATA:invalid_field' if any fields not valid.
            %
            %
            % Input:
            % ------
            % fields    -- A cellstr of field names to validate.
            %
            % Output:
            % indices   -- the indices corresponding to the fields
            %

            poss_fields = obj.FIELD_INDEX_MAP_;
            bad_fields = ~cellfun(@poss_fields.isKey, fields);
            if any(bad_fields)
                valid_fields = poss_fields.keys();
                error( ...
                    'HORACE:PixelData:invalid_argument', ...
                    'Invalid pixel field(s) {''%s''}.\nValid keys are: {''%s''}', ...
                    strjoin(fields(bad_fields), ''', '''), ...
                    strjoin(valid_fields, ''', ''') ...
                    );
            end

            indices = cellfun(@(field) poss_fields(field), fields, 'UniformOutput', false);
            indices = unique([indices{:}]);
        end
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    properties(Constant,Access=private)
        % list of fileldnames to save on hdd to be able to recover
        % all substantial parts of appropriate sqw file
        % Does not properly support filebased data. The decision is not to
        % save filebased data into mat files
        %fields_to_save_ = {'data','num_pixels','pix_range','file_path'};
        fields_to_save_ = {'metadata','data_wrap'};
    end

    methods
        function  ver  = classVersion(~)
            % serializable fields version
            ver = 2;
        end
        function flds = saveableFields(~)
            flds = PixelDataBase.fields_to_save_;
        end
        %------------------------------------------------------------------
    end
    methods(Access=protected)
        function val = check_set_prop(obj,fld,val)
            if isscalar(val)
                if ~isnumeric(val)
                    error('HORACCE:PixelDataBase:invalid_argument', ...
                        'single value for field %s have to be numeric scalar. It is %s', ...
                        fld,disp2str(val))
                end
            else
                if isvector(val) && ~isrow(val)
                    val = val';
                end
                if ~isnumeric(val) || size(val,1) ~=numel(obj.FIELD_INDEX_MAP_(fld))
                    error('HORACCE:PixelDataBase:invalid_argument', ...
                        'number of columns while setting fields: %s have to be equal to %d. It is %d', ...
                        fld,numel(obj.FIELD_INDEX_MAP_(fld)),size(val,1));
                end
            end
        end
        function obj = set_full_filename(obj,val)
            % main part of filepath setter. Need checks/modification
            if ~(ischar(val)||isstring(val))
                error('HORACE:PixelDataBase:invalid_argument',...
                    'full_filename should be a string, which describes file. It is: %s', ...
                    dis2str(val));
            end
            obj.full_filename_ = val;
        end
        function full_filename = get_full_filename(obj)
            full_filename = obj.full_filename_;
        end

        function val = get_data_wrap(obj)
            % main part of pix_data_wrap getter which allows overload for
            % different children
            val = pix_data(obj);
        end

        function obj =  set_metadata(obj,val)
            % main part of set from metadata setter
            if ~isa(val,'pix_metadata')
                error('HORACE:PixelDataBase:invalid_argument',...
                    'metadata can be set by the instance of pix_metadata class only. Provided class: %s', ...
                    class(val))
            end
            obj.full_filename_   = val.full_filename;
            obj.data_range_      = val.data_range;
            if obj.do_check_combo_arg
                obj = obj.check_combo_arg();
            end
        end
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
            % to allow loadob to recover new structure from an old structure.
            %
            if isfield(inputs,'num_pixels') % this is probably old pixels stored
                obj = build_from_old_pix_data_(obj,{inputs});
            elseif isa(inputs,'PixelData')
                % build from old PixelData stored in the file
                obj = build_from_old_pix_data_(obj,inputs);
            else
                if isfield(inputs,'array_dat')
                    obj = obj.from_bare_struct(inputs.array_dat);
                else
                    obj = obj.from_bare_struct(inputs);
                end
            end
        end
    end
end
