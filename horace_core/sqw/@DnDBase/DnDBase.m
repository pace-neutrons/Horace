classdef (Abstract)  DnDBase < SQWDnDBase
    % DnDBase Abstract base class for n-dimensional DnD object

    properties(Constant, Abstract, Access = protected)
        NUM_DIMS
    end
    properties(Constant,Access=protected)
        %fields_to_save_ = {'filename','filepath','title','alatt','angdeg',...
        %        'uoffset','u_to_rlu','ulen','label',...
        %        'dax','img_range','nbins_all_dims','s','e','npix'};

        fields_to_save = {'s','e','npix','proj','axes'}
    end

    % The depdendent props here have been created solely to retain the (old) DnD object API during the refactor.
    % These will be updated/removed at a later phase of the refactor when the class API is modified.
    properties(Dependent)
        % OLD DND object interface
        filename % Name of source sqw file that is being read, excluding path
        filepath % Path to sqw file that is being read, including terminating file separator
        title % Title of data structure
        alatt % Lattice parameters for data field (Ang^-1)
        angdeg % Lattice angles for data field (degrees)

        offset % Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]
        %u_to_rlu % Matrix (4x4) of projection axes in hkle representation
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
        %------------------------------------------------------------------
        % DND object interface
        s % Cumulative signal
        e % Cumulative variance
        npix % Number of contributing pixels to each bin of the plot axes

        proj %
    end
    properties(Hidden,Dependent)
        % the temporary property, which binds data_sqw_dnd and dnd object
        data
    end
    properties(Access = protected)
        s_    %cumulative signal for each bin of the image  size(data.s) == axes_block.dims_as_ssize)
        e_    %cumulative variance size(data.e) == axes_block.dims_as_ssize
        npix_ %No. contributing pixels to each bin of the plot axes. size(data.npix) == axes_block.dims_as_ssize
        axes_ = axes_block(); % axes block describing size and shape of the dnd object.
        proj_ = ortho_proj(); % Object defining the transformation, used to
        % convert coordinates in Crystal Cartesian coordinate system to the
        % dnd object image coordinate system
        isvalid_;
    end


    methods(Access = protected)
        function is = check_validity(obj)
            % overload this property to verify validity of interdependent
            % properties
            is = obj.isvalid_;
        end

        wout = unary_op_manager(obj, operation_handle);
        wout = binary_op_manager_single(w1, w2, binary_op);
        [ok, mess] = equal_to_tol_internal(w1, w2, name_a, name_b, varargin);

        wout = sqw_eval_pix_(wout, sqwfunc, ave_pix, pars);

        function obj = from_old_struct(obj,inputs)            
            % Restore object from the old structure, which describes the
            % previous version of the object.
            %
            % The method is called by loadobj in the case if the input
            % structure does not contain a version or the version, stored
            % in the structure does not correspond to the current version
            % of the class.
            %
            % By default, this function interfaces the default from_bare_struct
            % method, but when the old structure substantially differs from
            % the modern structure, this method needs the specific overloading
            % to allow loadobj to recover new structure from an old structure.
            %
            %if isfield(inputs,'version') % do checks for previous versions
            %   Add appropriate code to convert from specific version to
            %   modern version
            %end
            if isfield(inputs,'pax') && isfield(inputs,'iax')
                inputs.serial_name = 'axes_block';
                ab = serializable.from_struct(inputs);
                dat = data_sqw_dnd(ab,inputs);
                inputs = struct('data',dat);
            end

            if isfield(inputs,'array_dat')
                obj = obj.from_bare_struct(inputs.array_dat);
            else
                obj = obj.from_bare_struct(inputs);
            end
        end
    end

    methods (Static)
        function w = make_dnd(data_obj)
            if (isa(data_obj,'data_sqw_dnd'))
                ndims = size(data_obj.pax,2);
                if ndims == 0
                    w = d0d(data_obj);
                elseif ndims == 1
                    w = d1d(data_obj);
                elseif ndims == 2
                    w = d2d(data_obj);
                elseif ndims == 3
                    w = d3d(data_obj);
                elseif ndims == 4
                    w = d4d(data_obj);
                else
                    error('HORACE:DnDBase:invalid_argument', ...
                        'making dnd on data_sqw_dnd with wrong dimensions');
                end
            else
                error('HORACE:DnDBase:invalid_argument', ...
                    'make dnd on not data_sqw_dnd');
            end
        end

    end

    methods
        % function signatures
        w = sigvar_set(win, sigvar_obj);
        wout = copy(w);
        wout = cut_dnd_main (data_source, ndims, varargin);
        [val, n] = data_bin_limits (din);
        %TODO: when data_sqw_dnd inherits from DnDBase, enable this
        %      function. Ticket #730
        %function  save_xye(obj,varargin)
        %    % save data in xye format
        %    save_xye_(obj,varargin{:});
        %end

        %------------------------------------------------------------------
        % Accessors
        function pixels = has_pixels(w)
            % dnd object(s) do not have pixels
            pixels = false(size(w));
        end

        function obj = DnDBase(varargin)
            obj = obj@SQWDnDBase();

            args = parse_args_(obj,varargin{:});
            if args.array_numel>1
                obj = repmat(obj,args.array_size);
            elseif args.array_numel==0
                obj = init_from_loader_struct_(obj,args.data_struct);
            end
            for i=1:args.array_numel
                % i) copy
                if ~isempty(args.dnd_obj)
                    obj(i) = copy(args.dnd_obj(i));
                    % ii) struct
                elseif ~isempty(args.data_struct)
                    obj(i) = init_from_loader_struct_(obj(i),args.data_struct(i));
                    % iia) data_sqw_dnd_obj
                elseif ~isempty(args.data_sqw_dnd)
                    obj(i) = init_from_data_sqw_dnd_(obj(i),args.data_sqw_dnd(i));
                    % iii) filename
                elseif ~isempty(args.filename)
                    obj(i) = init_from_file_(obj(i),args.filename{i});
                    % iv) from sqw
                elseif ~isempty(args.sqw_obj)
                    obj(i) = init_from_sqw_(obj(i),args.sqw_obj(i));
                end
            end
        end
        % Public getters/setters expose all wrapped data attributes
        function obj = set.data(obj, d)
            if isa(d,'data_sqw_dnd')
                obj.s_ = d.s;
                obj.e_ = d.e;
                obj.npix_ = d.npix;
                obj.proj_ = d.get_projection();
                obj.axes_ = axes_block(d);
            elseif isempty(d)
                obj.s_ = [];
                obj.e_ = [];
                obj.npix_ = [];
                obj.proj_ = ortho_proj();
                obj.axes_ = axes_block();
            else
                error('HORACE:DnDBase:invalid_argument',...
                    'Only data_sqw_dnd class or empty value may be used as input for data. Got class: %s',...
                    class(d))
            end
        end
        %
        function val = get.filename(obj)
            val = obj.axes_.filename;
        end
        function obj = set.filename(obj, filename)
            obj.axes_.filename = filename;
        end
        %
        function val = get.filepath(obj)
            val = obj.axes_.filepath;
        end
        function obj = set.filepath(obj, filepath)
            obj.axes_.filepath = filepath;
        end
        %
        function val = get.title(obj)
            val = obj.axes_.title;
        end
        function obj = set.title(obj, title)
            obj.axes_.title = title;
        end
        %
        function val = get.alatt(obj)
            val = obj.proj_.alatt;
        end
        function obj = set.alatt(obj, alatt)
            obj.proj_.alatt = alatt;
        end
        %
        function val = get.angdeg(obj)
            val = obj.proj_.angdeg;
        end
        function obj = set.angdeg(obj, angdeg)
            obj.proj_.angdeg = angdeg;
        end
        %
        function val = get.offset(obj)
            obj.proj_.offset;
            val = [];
            if ~isempty(obj.data_)
                val = obj.data_.uoffset;
            end
        end
        %         function obj = set.uoffset(obj, uoffset)
        %             obj.data_.uoffset = uoffset;
        %         end
        %
        %         function val = get.u_to_rlu(obj)
        %             val = [];
        %             if ~isempty(obj.data_)
        %                 val = obj.data_.u_to_rlu;
        %             end
        %         end
        %         function obj = set.u_to_rlu(obj, u_to_rlu)
        %             obj.data_.u_to_rlu = u_to_rlu;
        %         end
        %         %
        %         function val = get.ulen(obj)
        %             val = [];
        %             if ~isempty(obj.data_)
        %                 val = obj.data_.ulen;
        %             end
        %         end
        %         function obj = set.ulen(obj, ulen)
        %             obj.data_.ulen = ulen;
        %         end
        %         %
        function val = get.label(obj)
            val = obj.axes_.label;
        end
        function obj = set.label(obj, label)
            obj.axes_.label = label;
        end
        %
        function val = get.iax(obj)
            val = obj.axes_.iax;
        end
        %
        function val = get.iint(obj)
            val = obj.axes_.iint;
        end
        %
        function val = get.pax(obj)
            val = obj.axes_.pax;
        end
        %
        function val = get.p(obj)
            val = obj.axes_.p;
        end
        %
        function val = get.dax(obj)
            val = obj.axes_.dax;
        end
        function obj = set.dax(obj, dax)
            obj.axes_.dax = dax;
        end
        %
        function val = get.s(obj)
            val = obj.s_;
        end
        function obj = set.s(obj, s)
            if ~isnumeric(s)
                error('HORACE:DnDBase:invalid_argument',...
                    'input signal must be numeric array')
            end
            obj.s_ = s;
            [~,~,obj] = check_combo_arg(obj);
        end
        %
        function val = get.e(obj)
            val = obj.e_;
        end
        function obj = set.e(obj, e)
            if ~isnumeric(e)
                error('HORACE:DnDBase:invalid_argument',...
                    'input variance must be numeric array')
            end
            obj.e_ = e;
            [~,~,obj] = check_combo_arg(obj);
        end
        %
        function val = get.npix(obj)
            val = obj.npix_;
        end
        function obj = set.npix(obj, npix)
            if ~isnumeric(npix)
                error('HORACE:DnDBase:invalid_argument',...
                    'input npix array must be numeric array')
            end
            obj.npix_ = npix;
            [~,~,obj] = check_combo_arg(obj);
        end
        %
        %         function obj = set.img_range(obj,val)
        %             obj.data_.img_range = val;
        %         end
        %         function range = get.img_range(obj)
        %             if isempty(obj.data_)
        %                 range  = [];
        %             else
        %                 range = obj.data_.img_range;
        %             end
        %         end
        %         %
        %         function obj = set.nbins_all_dims(obj,val)
        %             obj.data_.nbins_all_dims = val;
        %         end
        %         function nbins = get.nbins_all_dims(obj)
        %             if isempty(obj.data_)
        %                 nbins  = [];
        %             else
        %                 nbins = obj.data_.nbins_all_dims;
        %             end
        %         end
        %
        %------------------------------------------------------------------
        % Serializable interface
        %------------------------------------------------------------------
        function flds = saveableFields(obj)
            flds = obj.fields_to_save_;
        end
        function ver  = classVersion(~)
            ver = 3;
        end

        function [ok,mess,obj] = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained dnd object. Return the result of the check and the
            % reason for failure.
            %
            [ok,mess,obj] = check_combo_arg_(obj);
        end

    end
end

