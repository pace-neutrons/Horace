classdef (Abstract)  DnDBase < SQWDnDBase
    % DnDBase Abstract base class for n-dimensional DnD object

    properties(Access = protected)
        % CMDEV: removed, replaced with data_ on the superclass data % dnd_sqw_data instance
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

        args = parse_args_(obj, varargin);
        obj = init_from_sqw_(obj, sqw_obj);
        obj = init_from_file_(obj, in_filename);
        obj = init_from_loader_struct_(obj, data_struct);
    end

    methods
        % function signatures
        w = sigvar_set(win, sigvar_obj);
        [nd, sz] = dimensions(w);
        wout = copy(w);

        function obj = DnDBase(varargin)
            obj = obj@SQWDnDBase();

            [args] = obj.parse_args_(varargin{:});

            % i) copy
            if ~isempty(args.dnd_obj)
                obj = copy(args.dnd_obj);
            % ii) struct
            elseif ~isempty(args.data_struct)
                obj = obj.init_from_loader_struct_(args.data_struct);
            % iii) filename
            elseif ~isempty(args.filename)
                obj = obj.init_from_file_(args.filename);
            % iv) from sqw
            elseif ~isempty(args.sqw_obj)
                obj = obj.init_from_sqw_(args.sqw_obj);
            end
        end
        
        function pixels = has_pixels(~)
            pixels = false;
        end
            
        %% Public getters/setters expose all wrapped data attributes
        function val = get.filename(obj)
            val = '';
            if ~isempty(obj.data_)
                val = obj.data_.filename;
            end
        end
        function obj = set.filename(obj, filename)
            obj.data_.filename = filename;
        end

        function val = get.filepath(obj)
            val = '';
            if ~isempty(obj.data_)
                val = obj.data_.filepath;
            end
        end
        function obj = set.filepath(obj, filepath)
            obj.data_.filepath = filepath;
        end

        function val = get.title(obj)
            val = '';
            if ~isempty(obj.data_)
                val = obj.data_.title;
            end
        end
        function obj = set.title(obj, title)
            obj.data_.title = title;
        end

        function val = get.alatt(obj)
            val = [];
            if ~isempty(obj.data_)
                val = obj.data_.alatt;
            end
        end
        function obj = set.alatt(obj, alatt)
            obj.data_.alatt = alatt;
        end

        function val = get.angdeg(obj)
            val = [];
            if ~isempty(obj.data_)
                val = obj.data_.angdeg;
            end
        end
        function obj = set.angdeg(obj, angdeg)
            obj.data_.angdeg = angdeg;
        end

        function val = get.uoffset(obj)
            val = [];
            if ~isempty(obj.data_)
                val = obj.data_.uoffset;
            end
        end
        function obj = set.uoffset(obj, uoffset)
            obj.data_.uoffset = uoffset;
        end

        function val = get.u_to_rlu(obj)
            val = [];
            if ~isempty(obj.data_)
                val = obj.data_.u_to_rlu;
            end
        end
        function obj = set.u_to_rlu(obj, u_to_rlu)
            obj.data_.u_to_rlu = u_to_rlu;
        end

        function val = get.ulen(obj)
            val = [];
            if ~isempty(obj.data_)
                val = obj.data_.ulen;
            end
        end
        function obj = set.ulen(obj, ulen)
            obj.data_.ulen = ulen;
        end

        function val = get.ulabel(obj)
            val = [];
            if ~isempty(obj.data_)
                val = obj.data_.ulabel;
            end
        end
        function obj = set.ulabel(obj, ulabel)
            obj.data_.ulabel = ulabel;
        end

        function val = get.iax(obj)
            val = [];
            if ~isempty(obj.data_)
                val = obj.data_.iax;
            end
        end
        function obj = set.iax(obj, iax)
            obj.data_.iax = iax;
        end

        function val = get.iint(obj)
            val = [];
            if ~isempty(obj.data_)
                val = obj.data_.iint;
            end
        end
        function obj = set.iint(obj, iint)
            obj.data_.iint = iint;
        end

        function val = get.pax(obj)
            val = [];
            if ~isempty(obj.data_)
                val = obj.data_.pax;
            end
        end
        function obj = set.pax(obj, pax)
            obj.data_.pax = pax;
        end

        function val = get.p(obj)
            val = [];
            if ~isempty(obj.data_)
                val = obj.data_.p;
            end
        end
        function obj = set.p(obj, p)
            obj.data_.p = p;
        end

        function val = get.dax(obj)
            val = [];
            if ~isempty(obj.data_)
                val = obj.data_.dax;
            end
        end
        function obj = set.dax(obj, dax)
            obj.data_.dax = dax;
        end

        function val = get.s(obj)
            val = [];
            if ~isempty(obj.data_)
                val = obj.data_.s;
            end
        end
        function obj = set.s(obj, s)
            obj.data_.s = s;
        end

        function val = get.e(obj)
            val = [];
            if ~isempty(obj.data_)
                val = obj.data_.e;
            end
        end
        function obj = set.e(obj, e)
            obj.data_.e = e;
        end

        function val = get.npix(obj)
            val = [];
            if ~isempty(obj.data_)
                val = obj.data_.npix;
            end
        end
        function obj = set.npix(obj, npix)
            obj.data_.npix = npix;
        end
    end
end

