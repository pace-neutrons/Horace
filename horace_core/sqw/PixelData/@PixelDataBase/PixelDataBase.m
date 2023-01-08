classdef (Abstract) PixelDataBase < handle
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
    properties(Hidden)
        PIXEL_BLOCK_COLS_ = PixelDataBase.DEFAULT_NUM_PIX_FIELDS;
        num_pixels_ = 0;  % the number of pixels in the object
        raw_data_ = zeros(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 0);  % the underlying data cached in the object
        pix_range_ = PixelDataBase.EMPTY_RANGE_; % range of pixels in Crystal Cartesian coordinate system
        object_id_;  % random unique identifier for this object, used for tmp file names
        file_path_ = '';
    end

    properties (Constant, Hidden)
        DATA_POINT_SIZE = 8;  % num bytes in a double
        DEFAULT_NUM_PIX_FIELDS = 9;
    end
    properties(Dependent,Hidden)
        DEFAULT_PAGE_SIZE;
    end

    properties (Constant,Hidden)
        % the coordinate range, an empty pixel class has
        EMPTY_RANGE_ = [inf,inf,inf,inf;-inf,-inf,-inf,-inf];
        % the version of the class to store/restore data in Matlab files
        version = 1;
    end

    properties(Dependent, Hidden)
        % points to raw_data_ but with a layer of validation for setting correct array sizes
        data_;
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
        % list of the fields, used for exporting PixelData class to
        % structure
        % Does not properly support filebased data. The decision is not to
        % save filebased data into mat files
        fields_to_save_ = {'data','num_pixels','pix_range','file_path'};
    end

    properties (Dependent)
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

        data; % The full raw pixel data block. Usage of this attribute exposes
        % current pixels layout, so when the pixels layout changes in a
        % future, the code using this attribute will change too. So, the usage
        % of this attribute is discouraged as the structure of the return
        % value is not guaranteed in a future.

        base_page_size;  % The number of pixels that can fit in one page of data
    end

    methods (Static)
        function obj = create(init, mem_alloc, upgrade, file_backed)
            % Factory to construct a PixelData object from the given data. Default
            % construction initialises the underlying data as an empty (9 x 0)
            % array.
            %
            %   >> obj = PixelDataBase.create(ones(9, 200))
            %
            %   >> obj = PixelDataBase.create(200)  % initialise 200 pixels with underlying data set to zero
            %
            %   >> obj = PixelDataBase.create(file_path)  % initialise pixel data from an sqw file
            %
            %   >> obj = PixelDataBase.create(faccess_reader)  % initialise pixel data from an sqw file reader
            %
            %   >> obj = PixelDataBase.create(faccess_reader, mem_alloc)  % set maximum memory allocation
            %
            %>> obj = PixelDataBase.create(__,false) -- not upgrade class averages
            %         (pix_range) for old file format, if these averages
            %         are not stored in the file. Default -- true. Pixel
            %         averages are calculated on construction
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
            %
            %  mem_alloc    The maximum amount of memory allocated to hold pixel
            %               data in bytes. If pixels cannot all be held in memory
            %               at one time, they will be loaded from the file
            %               (specified by 'init') when they are required. This
            %               argument does nothing if the class is constructed with
            %               in-memory data. (Optional)
            %

            if nargin == 0
                obj = PixelDataMemory();
                return
            end

            if ~exist('file_backed', 'var') || isempty(file_backed)
                file_backed = false;
            end

            if ~exist('mem_alloc', 'var')
                mem_alloc = get(hor_config, 'mem_chunk_size');
            end

            if ~exist('upgrade', 'var')
                upgrade = true;
            end

            % In memory construction
            if isstruct(init)
                if ~isfield(init,'version')
                    fnms = fieldnames(init);
                    if all(ismember(PixelDataBase.fields_to_save_,fnms)) % the current pixdata structure
                        % provided as input
                        if numel(init) > 1 % the same as saveobj
                            init = struct('version',PixelDataBase.version,...
                                'array_data',init);
                        else
                            init.version = PixelDataBase.version;
                        end
                    end
                    %else: some unknown structure. May be saved earlier without version?
                    % let loadobj check its validity
                end
                obj = PixelDataBase.loadobj(init);

            elseif isa(init, 'PixelDataMemory')
                if file_backed
                    obj = PixelDataFileBacked(init, mem_alloc);                    
                else
                    obj = PixelDataMemory(init);
                end

                % if the file exists we can create a file-backed instance
            elseif isa(init, 'PixelDataFileBacked')
                if file_backed
                    obj = PixelDataFileBacked(init, mem_alloc);
                else
                    obj = PixelDataMemory(init);
                end

            elseif numel(init) == 1 && isnumeric(init) && floor(init) == init
                % input is an integer
                if file_backed
                    obj = PixelDataFileBacked(init, mem_alloc);                    
                else
                    obj = PixelDataMemory(init);
                end

            elseif isnumeric(init)
                % Input is data array
                if  file_backed
                    obj = PixelDataFileBacked(init, mem_alloc);                    
                else
                    obj = PixelDataMemory(init);                    
                end

                % File-backed construction
            elseif ischar(init)
                % input is a file path
                if ~is_file(init)
                    error('HORACE:PixelDataFileBacked:invalid_argument', ...
                        'Cannot find file to load (%s)', init)
                end
                init = sqw_formats_factory.instance().get_loader(init);
                if (init.npixels > 9*mem_alloc) || file_backed
                    obj = PixelDataFileBacked(init, mem_alloc);                    
                else
                    obj = PixelDataMemory(init);                    
                end

            elseif isa(init, 'sqw_file_interface')
                % input is a file accessor
                if (init.npixels > 9*mem_alloc) || file_backed
                    obj = PixelDataFileBacked(init, mem_alloc);                    
                else
                    obj = PixelDataMemory(init);
                end
            else
                error('HORACE:PixelDataBase:invalid_argument', ...
                    'Cannot create a PixelData object from class (%s)', ...
                    class(init))
            end

            if upgrade
                arrayfun(@(x) x.reset_changed_coord_range('coordinates'), obj);
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

        function obj = loadobj(S)
            % Load a PixelData object from a .mat file
            %
            %>> obj = PixelDataBase.loadobj(S)
            % Input:
            % ------
            %   S       Data, produced by saveobj operation and stored
            %           in .mat file
            % Output:
            % -------
            %   obj     An instance of PixelData object or array of objects
            %
            obj = loadobj_(S);
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
        obj = recalc_pix_range(obj);
        set_data(obj, fields, data, abs_pix_indices);

        data=saveobj(obj);
        has_more = has_more(obj);
        [current_page_num, total_num_pages] = advance(obj, varargin);

        prp = get_prop(obj, ind);
        set_prop(obj, ind, val);

        data = get_raw_data(obj);
        set_raw_data(obj, val);

    end

    methods

        function data = get.data_(obj)
            data = obj.get_raw_data();
        end

        function set.data_(obj, val)
            obj.set_raw_data(val);
        end

        function data = get.data(obj)
            data = obj.get_prop('all');
        end

        function set.data(obj, val)
            obj.set_prop('all', val);
        end

        function u1 = get.u1(obj)
            u1 = obj.get_prop('u1');
        end

        function set.u1(obj, val)
            obj.set_prop('u1', val);
        end

        function u2 = get.u2(obj)
            u2 = obj.get_prop('u2');
        end

        function set.u2(obj, val)
            obj.set_prop('u2', val);
        end

        function u3 = get.u3(obj)
            u3 = obj.get_prop('u3');
        end

        function set.u3(obj, val)
            obj.set_prop('u3', val);
        end

        function dE = get.dE(obj)
            dE = obj.get_prop('dE');
        end

        function set.dE(obj, val)
            obj.set_prop('dE', val);
        end

        function q_coordinates = get.q_coordinates(obj)
            q_coordinates = obj.get_prop('q_coordinates');
        end

        function set.q_coordinates(obj, val)
            obj.set_prop('q_coordinates', val);
        end

        function coordinates = get.coordinates(obj)
            coordinates = obj.get_prop('coordinates');
        end

        function set.coordinates(obj, val)
            obj.set_prop('coordinates', val);
        end

        function run_idx = get.run_idx(obj)
            run_idx = obj.get_prop('run_idx');
        end

        function set.run_idx(obj, val)
            obj.set_prop('run_idx', val);
        end

        function detector_idx = get.detector_idx(obj)
            detector_idx = obj.get_prop('detector_idx');
        end

        function set.detector_idx(obj, val)
            obj.set_prop('detector_idx', val);
        end

        function energy_idx = get.energy_idx(obj)
            energy_idx = obj.get_prop('energy_idx');
        end

        function set.energy_idx(obj, val)
            obj.set_prop('energy_idx', val);
        end

        function signal = get.signal(obj)
            signal = obj.get_prop('signal');
        end

        function set.signal(obj, val)
            obj.set_prop('signal', val);
        end

        function variance = get.variance(obj)
            variance = obj.get_prop('variance');
        end

        function set.variance(obj, val)
            obj.set_prop('variance', val);
        end

        function range = get.pix_range(obj)
            range = obj.pix_range_;
        end

        function set.pix_range(obj, pix_range)
            set_range(obj, pix_range);
        end

        function ps = get.DEFAULT_PAGE_SIZE(~)
            ps = config_store.instance().get_value('hor_config', 'mem_chunk_size');
        end
    end

    methods
        function set_range(obj,pix_range)
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
            if any(size(pix_range) ~= [2,4])
                error('HORACE:PixelData:InvalidArgument',...
                    'pixel_range should be [2x4] array');
            end
            obj.pix_range_ = pix_range;
        end

        function pix_copy = copy(obj)
            % Make an independent copy of this object
            %  This method simply constructs a new PixelData instance by calling
            %  the constructor with the input object as an argument. Because of
            %  this, any properties that need to be explicitly copied must be
            %  copied within this class' 'copy-constructor'.
            pix_copy = PixelDataBase.create(obj, obj.page_memory_size_, false, obj.is_filebacked);
        end

        function is_empty = isempty(obj)
            % Return true if the PixelData object holds no pixel data
            is_empty = obj.num_pixels == 0;
        end

        function num_pix = get.num_pixels(obj)
            num_pix = obj.num_pixels_;
        end

        function page_size = calculate_page_size_(obj, mem_alloc)
            % Calculate number of pixels that fit in the given memory allocation
            page_size = max(mem_alloc, size(obj.raw_data_, 2));
        end

        function page_size = get.base_page_size(obj)
            page_size = calculate_page_size_(obj,obj.page_memory_size_);
        end

        function obj = move_to_first_page(obj)
            % Reset the object to point to the first page of pixel data in the file
            % and clear the current cache
            %  This function does nothing if pixels are not file-backed.
            %
            obj.move_to_page(1);
        end

        function st = struct(obj)
            % convert object into saveable and serializable structure
            %
            flds = obj.fields_to_save_;

            cell_dat = cell(numel(flds),numel(obj));
            for j=1:numel(obj)
                for i=1:numel(flds)
                    fldn = flds{i};
                    cell_dat{i,j} = obj(j).(fldn);
                end
            end
            st = cell2struct(cell_dat,flds,1);
            if numel(obj)>1
                st = reshape(st,size(obj));
            end
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

end
