classdef (Abstract)  DnDBase < SQWDnDBase
    % DnDBase Abstract base class for n-dimensional DnD object

    properties(Access = protected)
        data % dnd_sqw_data instance
    end

    properties(Constant, Abstract, Access = protected)
       NUM_DIMS
    end

    properties(Dependent)
        filename
        filepath
        title
        alatt
        angdeg
        uoffset
        u_to_rlu
        ulen
        ulabel
        iax
        iint
        pax
        p
        dax
        s
        e
        npix
    end

    methods (Access = protected)
        [ok, mess] = equal_to_tol_internal(w1, w2, name_a, name_b, varargin);
    end

    methods
        % function signatures
        [nd, sz] = dimensions(w)
        wout = copy(w)


        function obj = DnDBase(varargin)
            obj = obj@SQWDnDBase();
        end

        % Wrapped data attributes
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

