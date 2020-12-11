classdef (Abstract)  DnDBase < SQWDnDBase
    % DnDBase Abstract base class for n-dimensional DnD object

    properties(Access = protected)
        data % dnd_sqw_data instance
    end

    properties(Constant, Abstract, Access = protected)
       NUM_DIMS
    end

    % The depdendent props here have been created solely to retain the (old) DnD object API during the refactor.
    % These will be updated/removed at a later phase of the refactor when the class API is modified.
    properties(Dependent)
        filename % Name of source sqw file that is being read, excluding path
        filepath % Path to sqw file that is being read, including terminating file separator
        title % Title of data structure
        alatt % Lattice parameters for data field (Ang^-1)
        angdeg % Lattice angles for data field (degrees)
        uoffset % Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]
        u_to_rlu % Matrix (4x4) of projection axes in hkle representation
                 %     u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
        ulen % Length of projection axes vectors in Ang^-1 or meV [row vector]
        ulabel  % Labels of the projection axes [1x4 cell array of character strings]
        iax % Index of integration axes into the projection axes  [row vector]
            %     Always in increasing numerical order, data.iax=[1,3] means summation has been performed along u1 and u3 axes
        iint % Integration range along each of the integration axes. [iint(2,length(iax))]
             %     e.g. in 2D case above, is the matrix vector [u1_lo, u3_lo; u1_hi, u3_hi]
        dax %Index into data.pax of the axes for display purposes. [row vector]
        p % Cell array containing bin boundaries along the plot axes [column vectors]
          %                       i.e. row cell array{data.p{1}, data.p{2} ...}
        pax % Index of plot axes into the projection axes  [row vector]
        s % Cumulative signal
        e % Cumulative variance
        npix % Number of contributing pixels to each bin of the plot axes
    end

    methods(Access = protected)
        wout = unary_op_manager(obj, operation_handle);
        wout = binary_op_manager_single(w1, w2, binary_op);
        [ok, mess] = equal_to_tol_internal(w1, w2, name_a, name_b, varargin);

        function args = parse_args(obj, varargin)
            % Parse a single argument passed to the DnD constructor
            %
            % Return struct with the data set to the appropriate element:
            % args.filename  % string, presumed to be filename
            % args.dnd_obj   % DnD class instance
            % args.sqw_obj   % SQW class instance
            % args.data_struct % generic struct, presumed to represent DnD
            parser = inputParser();
            parser.addOptional('input', [], @(x) (isa(x, 'SQWDnDBase') || is_string(x) || isstruct(x)));
            parser.KeepUnmatched = true;
            parser.parse(varargin{:});

            input = parser.Results.input;
            args = struct('dnd_obj', [], 'sqw_obj', [], 'filename', [], 'data_struct', []);

            if isa(input, 'SQWDnDBase')
                if isa(input, class(obj))
                    args.dnd_obj = input;
                elseif isa(input, 'sqw')
                    args.sqw_obj = input;
                else
                    error([upper(class(obj)), ':' class(obj)], ...
                        [upper(class(obj)) ' cannot be constructed from an instance of this object "' class(input) '"']);
                end
            elseif is_string(parser.Results.input)
                args.filename = input;
            elseif isstruct(input) && ~isempty(input)
                args.data_struct = input;
            else
                % create struct holding default instance
                args.data_struct = data_sqw_dnd(obj.NUM_DIMS);
            end
        end

        function obj = init_from_sqw(obj, sqw_obj)
            sqw_dim = sqw_obj.dimensions();
            if sqw_dim ~= obj.NUM_DIMS
                error([upper(class(obj)), ':' class(obj)], ...
                    ['SQW object cannot be converted to a ' num2str(obj.NUM_DIMS) 'd dnd-type object']);
            end
            obj.data = sqw_obj.data;
        end

        function obj = init_from_loader_struct(obj, data_struct)
            obj.data = data_struct;
        end

        function obj = init_from_file(obj, in_filename)
            % Parse DnD from file
            %
            % An error is raised if the data file is identified not a correctly
            % dimensioned DnD object
            ldr = sqw_formats_factory.instance().get_loader(in_filename);
            if ~strcmpi(ldr.data_type, 'b+') % not a valid dnd-type structure
                error([upper(class(obj)), ':' class(obj)], ...
                    'Data file does not contain valid dnd-type object');
            end
            if ldr.num_dim ~= obj.NUM_DIMS
                error([upper(class(obj)), ':' class(obj)], ...
                    ['Data file does not contain ' num2str(obj.NUM_DIMS) 'd dnd-type object']);
            end

            [~, ~, ~, dnd_data] = ldr.get_dnd('-legacy');
            obj = obj.init_from_loader_struct(dnd_data);
        end
    end

    methods
        % function signatures
        w = sigvar_set(win, sigvar_obj);
        [nd, sz] = dimensions(w);
        wout = copy(w);

        function obj = DnDBase(varargin)
            obj = obj@SQWDnDBase();
        end

        %% Public getters/setters expose all wrapped data attributes
        function val = get.filename(obj)
            val = '';
            if ~isempty(obj.data)
                val = obj.data.filename;
            end
        end
        function obj = set.filename(obj, filename)
            obj.data.filename = filename;
        end

        function val = get.filepath(obj)
            val = '';
            if ~isempty(obj.data)
                val = obj.data.filepath;
            end
        end
        function obj = set.filepath(obj, filepath)
            obj.data.filepath = filepath;
        end

        function val = get.title(obj)
            val = '';
            if ~isempty(obj.data)
                val = obj.data.title;
            end
        end
        function obj = set.title(obj, title)
            obj.data.title = title;
        end

        function val = get.alatt(obj)
            val = [];
            if ~isempty(obj.data)
                val = obj.data.alatt;
            end
        end
        function obj = set.alatt(obj, alatt)
            obj.data.alatt = alatt;
        end

        function val = get.angdeg(obj)
            val = [];
            if ~isempty(obj.data)
                val = obj.data.angdeg;
            end
        end
        function obj = set.angdeg(obj, angdeg)
            obj.data.angdeg = angdeg;
        end

        function val = get.uoffset(obj)
            val = [];
            if ~isempty(obj.data)
                val = obj.data.uoffset;
            end
        end
        function obj = set.uoffset(obj, uoffset)
            obj.data.uoffset = uoffset;
        end

        function val = get.u_to_rlu(obj)
            val = [];
            if ~isempty(obj.data)
                val = obj.data.u_to_rlu;
            end
        end
        function obj = set.u_to_rlu(obj, u_to_rlu)
            obj.data.u_to_rlu = u_to_rlu;
        end

        function val = get.ulen(obj)
            val = [];
            if ~isempty(obj.data)
                val = obj.data.ulen;
            end
        end
        function obj = set.ulen(obj, ulen)
            obj.data.ulen = ulen;
        end

        function val = get.ulabel(obj)
            val = [];
            if ~isempty(obj.data)
                val = obj.data.ulabel;
            end
        end
        function obj = set.ulabel(obj, ulabel)
            obj.data.ulabel = ulabel;
        end

        function val = get.iax(obj)
            val = [];
            if ~isempty(obj.data)
                val = obj.data.iax;
            end
        end
        function obj = set.iax(obj, iax)
            obj.data.iax = iax;
        end

        function val = get.iint(obj)
            val = [];
            if ~isempty(obj.data)
                val = obj.data.iint;
            end
        end
        function obj = set.iint(obj, iint)
            obj.data.iint = iint;
        end

        function val = get.pax(obj)
            val = [];
            if ~isempty(obj.data)
                val = obj.data.pax;
            end
        end
        function obj = set.pax(obj, pax)
            obj.data.pax = pax;
        end

        function val = get.p(obj)
            val = [];
            if ~isempty(obj.data)
                val = obj.data.p;
            end
        end
        function obj = set.p(obj, p)
            obj.data.p = p;
        end

        function val = get.dax(obj)
            val = [];
            if ~isempty(obj.data)
                val = obj.data.dax;
            end
        end
        function obj = set.dax(obj, dax)
            obj.data.dax = dax;
        end

        function val = get.s(obj)
            val = [];
            if ~isempty(obj.data)
                val = obj.data.s;
            end
        end
        function obj = set.s(obj, s)
            obj.data.s = s;
        end

        function val = get.e(obj)
            val = [];
            if ~isempty(obj.data)
                val = obj.data.e;
            end
        end
        function obj = set.e(obj, e)
            obj.data.e = e;
        end

        function val = get.npix(obj)
            val = [];
            if ~isempty(obj.data)
                val = obj.data.npix;
            end
        end
        function obj = set.npix(obj, npix)
            obj.data.npix = npix;
        end
    end
end

