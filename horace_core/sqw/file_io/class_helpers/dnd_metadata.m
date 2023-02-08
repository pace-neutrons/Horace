classdef dnd_metadata < serializable
    %DND_METADATA The class describes DND object image and
    %contains all information, describing this image.
    %
    % The purpose of this class is storing/restoring DnD object metadata
    % into custom bindary file.
    %
    properties(Dependent)
        %------------------------------------------------------------------
        % Old headers interface
        title;      % Title of sqw data structure, displayed on plots.
        filename;   % Name of sqw file that is being read, excluding path. Used in titles
        filepath;   % Path to sqw file that is being read, including terminating file separator.
        %            Used in titles
        %------------------------------------------------------------------
        dimensions;
        axes;
        proj;
        img_range
        creation_date_str;
        creation_date_defined
    end
    properties(Dependent,Hidden)
        % dnd interface present on old dnd files and used in header
        alatt % Lattice parameters for data field (Ang^-1)
        angdeg % Lattice angles for data field (degrees)

        offset % Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]
        u_to_rlu % Matrix (4x4) of projection axes in hkle representation
        %     u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
        %ulen % Length of projection axes vectors in Ang^-1 or meV [row vector]
        label  % Labels of the projection axes [1x4 cell array of character strings]
        iax % Index of integration axes into the projection axes  [row vector]
        %     Always in increasing numerical order, data.iax=[1,3] means summation has been performed along u1 and u3 axes
        iint % Integration range along each of the integration axes. [iint(2,length(iax))]
        %     e.g. in 2D case above, is the matrix vector [u1_lo, u3_lo; u1_hi, u3_hi]
        dax %Index into data.pax of the axes for display purposes. [row vector]
        p % Cell array containing bin boundaries along the plot axes [column vectors]
        %                       i.e. row cell array{data.p{1}, data.p{2} ...}
        pax % Index of plot axes into the projection axes  [row vector]
        %
        ulen;
        %
        creation_date;
    end
    properties(Access=protected)
        axes_ = axes_block();
        proj_ = ortho_proj();
        %
        creation_date_ = '';
        creation_date_defined_ = false;
    end
    %======================================================================
    % OLD Interface
    methods
        function alat = get.alatt(obj)
            alat = obj.proj_.alatt;
        end
        function ad = get.angdeg(obj)
            ad = obj.proj_.angdeg;
        end
        function off = get.offset(obj)
            off = obj.proj_.offset;
        end
        function urlu = get.u_to_rlu(obj)
            urlu = obj.proj_.u_to_rlu;
        end
        function ulen = get.ulen(obj)
            ulen = obj.axes_.ulen;
        end
        function lbl = get.label(obj)
            lbl = obj.axes_.label;
        end
        function iax = get.iax(obj)
            iax= obj.axes_.iax;
        end
        function iint = get.iint(obj)
            iint = obj.axes_.iint;
        end
        function dax= get.dax(obj)
            dax = obj.axes_.dax;
        end
        function p = get.p(obj)
            p = obj.axes_.p;
        end
        function pax = get.pax(obj)
            pax = obj.axes_.pax;
        end
        function cd = get.creation_date(obj)
            cd = obj.creation_date_;
        end
    end


    methods
        function obj = dnd_metadata(varargin)
            %DND_METADATA Construct an instance of metadata class
            %
            % the dnd_metadata class can be constructed only from DnD type
            % object
            if nargin == 0
                return;
            end
            dnd_obj = varargin{1};
            if isa(dnd_obj,'DnDBase')
                obj.axes = dnd_obj.axes;
                obj.proj = dnd_obj.proj;
                if dnd_obj.creation_date_defined
                    obj.creation_date_str = dnd_obj.creation_date;
                end
            else
                flds = obj.saveableFields();
                [obj,remains] = obj.set_positional_and_key_val_arguments(...
                    flds,false,varargin{:});
                if ~isempty(remains)
                    error('HORACE:dnd_metadata:invalid_argument',...
                        ' Class constructor has been invoked with non-recognized parameters: %s',...
                        disp2str(remains));
                end
            end
        end
        function range= get.img_range(obj)
            range = obj.axes_.img_range;
        end
        %------------------------------------------------------------------
        % Re-wiring for old dnd metadata methods
        function tit = get.title(obj)
            % Title of sqw data structure, displayed on plots.
            tit = obj.axes_.title;
        end
        function obj = set.title(obj,val)
            obj.axes_.title = val;
        end
        function fn = get.filename(obj)
            % Name of sqw file that is being read, excluding path. Used in titles
            fn = obj.axes_.filename;
        end
        function obj = set.filename(obj,val)
            % Name of sqw file that is being read, excluding path. Used in titles
            obj.axes_.filename = val;
        end
        function fp = get.filepath(obj)
            % Path to sqw file that is being read, including terminating file separator.
            %            Used in titles
            fp = obj.axes_.filepath;
        end
        function obj = set.filepath(obj,val)
            % Path to sqw file that is being read, including terminating file separator.
            %            Used in titles
            obj.axes_.filepath = val;
        end
        %------------------------------------------------------------------
        function nd = get.dimensions(obj)
            if isempty(obj.axes_)
                nd = [];
                return
            end
            nd = obj.axes_.dimensions;
        end
        function ab = get.axes(obj)
            ab = obj.axes_;
        end
        function pr = get.proj(obj)
            pr = obj.proj_;
        end
        function cd = get.creation_date_str(obj)
            if obj.creation_date_defined_
                cd_dt = obj.creation_date_;
                cd = main_header_cl.convert_datetime_to_str(cd_dt);
            else
                cd = '';
                return;
            end

        end
        function def = get.creation_date_defined(obj)
            def = obj.creation_date_defined_;
        end
        %------------------------------------------------------------------
        function obj = set.axes(obj,val)
            if ~isa(val,'axes_block')
                error('HORACE:dnd_metadata:invalid_argument', ...
                    'you can set axes using an instance of axes_block class only. Input class is: %s', ...
                    class(val));
            end
            obj.axes_ = val;
        end
        function obj = set.proj(obj,val)
            if ~isa(val,'aProjection')
                error('HORACE:dnd_metadata:invalid_argument', ...
                    'you can set proj using an instance of aProjection class only. Input class is: %s', ...
                    class(val));
            end
            obj.proj_ = val;
        end
        function obj = set.creation_date_str(obj,val)
            if isempty(val)
                obj.creation_date_  = '';
                obj.creation_date_defined_ = false;
            else
                obj.creation_date_ = main_header_cl.check_datetime_valid(val);
                obj.creation_date_defined_ = true;
            end
        end
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    methods
        function S = saveobj(obj)
            if ~obj.creation_date_defined_
                obj.creation_date_ = datetime('now');
                obj.creation_date_defined_ = true;
            end
            S = saveobj@serializable(obj);
        end
        function ver  = classVersion(~)
            ver = 1;
        end
        function flds = saveableFields(~)
            % Return cellarray of public property names, which fully define
            % the state of a serializable object, so when the field values are
            % provided, the object can be fully restored from these values.
            %
            flds = {'axes','proj','creation_date_str'};
        end
    end
end