classdef (Abstract)  DnDBase < SQWDnDBase & dnd_plot_interface
    % DnDBase Abstract base class for n-dimensional DnD object

    properties(Abstract,Dependent,Access = protected)
        NUM_DIMS
    end
    properties(Constant,Access=protected)
        %fields_to_save_ = {'filename','filepath','title','alatt','angdeg',...
        %        'uoffset','u_to_rlu','ulen','label',...
        %        'dax','img_range','nbins_all_dims','s','e','npix'};

        % order of the components defines the order of the inputs, accepted
        % by constructor without the arguments
        fields_to_save_ = {'axes','proj','s','e','npix'}
    end

    % The dependent props here have been created solely to retain the (old) DnD object API during the refactor.
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
        %
        nbins;    % number of bins in the data array
        img_range % the whole 4D range of the object in appropriate axes
        %           coordinate system
        %------------------------------------------------------------------
        % DND object interface
        s % Cumulative signal
        e % Cumulative variance
        npix % Number of contributing pixels to each bin of the plot axes

        axes % access to the axes block class directly
        proj % access to projection class directly
    end
    properties(Dependent,Hidden)
        % legacy operations, necessary for saving dnd object in the old sqw
        % data format. Will be removed when old sqw format saving is
        % removed
        u_to_rlu;
        ulen;
    end
    properties(Access = protected)
        s_    %cumulative signal for each bin of the image  size(data.s) == axes_block.dims_as_ssize)
        e_    %cumulative variance size(data.e) == axes_block.dims_as_ssize
        npix_ %No. contributing pixels to each bin of the plot axes. size(data.npix) == axes_block.dims_as_ssize
        axes_ = axes_block(); % axes block describing size and shape of the dnd object.
        proj_ = ortho_proj(); % Object defining the transformation, used to convert data from
        %                      crystal Cartesian coordinate system to this
        %                      image coordinate system.
    end

    methods (Static)
        function w = dnd(varargin)
            % create dnd object with size and dimensions, defined by inputs
            %
            ndims = found_dims_(varargin{:});
            argi = varargin;
            switch(ndims)
                case(0)
                    w = d0d(argi{:});
                case(1)
                    w = d1d(argi{:});
                case(2)
                    w = d2d(argi{:});
                case(3)
                    w = d3d(argi{:});
                case(4)
                    w = d4d(argi{:});
                otherwise
                    error('HORACE:DnDBase:invalid_argument', ...
                        'can not build dnd object with %d dimensions', ...
                        ndims);
            end
        end
    end

    methods
        % function signatures:
        %------------------------------------------------------------------
        [q,en]=calculate_q_bins(win); % Calculate qh,qk,ql,en for the centres
        %                             % of the bins of an n-dimensional sqw
        %                             % or dnd dataset
        qw=calculate_qw_bins(win,optstr) % Calculate qh,qk,ql,en for the
        %                             % centres of the bins of an n-dimensional
        %                             % sqw or dnd dataset.
        [val, n] = data_bin_limits(obj); % Get limits of the data in an
        %                             % n-dimensional dataset, that is,find the
        %                             % coordinates along each of the axes
        %                             % of the smallest cuboid that contains
        %                             % bins with non-zero values of contributing pixels.
        % sigvar block
        %------------------------------------------------------------------
        sob = sigvar(w);
        [s,var,mask_null] = sigvar_get (w);
        w = sigvar_set(win, sigvar_obj);
        sz = sigvar_size(w);
        %------------------------------------------------------------------
        function obj=signal(obj,varargin)
            error('HORACE:DnDBase:runtime_error',...
                'Call to signal function is possible for sqw objects only')
        end
        wout = cut(obj, varargin); % take cut from the dnd object
        function wout = cut_dnd(obj,varargin)
            % legacy entrance to cut
            wout = obj.cut(varargin{:});
        end
        function wout = cut_sqw(obj,varargin)
            % throw on cut_sqw on dnd object
            error('HORACE:DnDBase:invalid_argument', ...
                'Can not run cut_sqw on dnd object');
        end
        %------------------------------------------------------------------
        %
        [wout,mask_array] = mask(win, mask_array);

        %------------------------------------------------------------------
        [wout_disp, wout_weight] = dispersion(win, dispreln, varargin);
        wout = disp2sqw(win, dispreln, pars, fwhh,varargin); % calculate
        %                             % dispersion function on the dnd object
        wout = func_eval(win, func_handle, pars, varargin);  % calculate the
        %                             % function, provided as input on the
        %                             % bin centers of the image axes
        %------------------------------------------------------------------
        %
        varargout = head(obj,vararin);
        wout = copy(w);
        % rebin an object to the other object with the dimensionality
        % smaller then the dimensionality of the current object
        obj = rebin(obj,varargin);
        %
        save_xye(obj,varargin)  % save data in xye format
        s=xye(w, null_value);   % Get the bin centres, intensity and error bar for a 1D, 2D, 3D or 4D dataset
        % smooth dnd object or array of dnd objects
        wout = smooth(win, varargin)

        % Change the crystal lattice and orientation of an sqw object or array of objects
        wout = change_crystal(win,varargin);
        %------------------------------------------------------------------
        % Accessors
        function pixels = has_pixels(w)
            % dnd object(s) do not have pixels
            pixels = false(size(w));
        end
        %
        function obj = init(obj,varargin)
            % initialize empty object with any possible input arguments
            % Part of the object constructor
            args = parse_args_(obj,varargin{:});
            if args.array_numel>1
                obj = repmat(obj,args.array_size);
            elseif args.array_numel==0
                obj = obj.from_bare_struct(args.data_struct);
            end
            for i=1:args.array_numel
                % i) copy
                if ~isempty(args.dnd_obj)
                    if args.dnd_obj.dimensions == obj.dimensions
                        obj(i) = copy(args.dnd_obj(i));
                    else % rebin the input object to the object
                        %  with the dimensionality, smaller then the
                        %  dimensionalify of the input object.
                        %  Bigger dimensionality will be rejected.
                        %
                        obj(i) = rebin(obj(i),args.dnd_obj(i));
                    end
                    % ii) struct
                elseif ~isempty(args.data_struct)
                    obj(i) = obj(i).from_bare_struct(args.data_struct(i));
                elseif ~isempty(args.set_of_fields)
                    keys = obj.saveableFields();
                    obj(i) = set_positional_and_key_val_arguments(obj,...
                        keys,false,args.set_of_fields{:});
                    % copy label from projection to axes block in case it
                    % has been redefined on projection
                    is_proj = cellfun(@(x)isa(x,'aProjection'),args.set_of_fields);
                    if any(is_proj)
                        obj(i).axes.label = args.set_of_fields{is_proj}.label;
                    end
                elseif ~isempty(args.sqw_obj)
                    obj(i) = args.sqw_obj(i).data;
                end
            end
        end

        function obj = DnDBase(varargin)
            obj = obj@SQWDnDBase();
            if nargin>0
                obj = obj.init(varargin{:});
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
            val = obj.proj_.offset;
        end
        function obj = set.offset(obj,val)
            obj.proj_.offset = val;
            obj.axes_.img_range = obj.axes_.img_range+obj.proj_.offset;
        end

        function val = get.u_to_rlu(obj)
            val = obj.proj.u_to_rlu;
        end
        %         function obj = set.u_to_rlu(obj, u_to_rlu)
        %             obj.data_.u_to_rlu = u_to_rlu;
        %         end
        %         %
        function val = get.ulen(obj)
            val = obj.axes.ulen;
        end
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
        %------------------------------------------------------------------
        % MODERN dnd interface
        %------------------------------------------------------------------
        function val = get.s(obj)
            val = obj.s_;
        end
        function obj = set.s(obj, s)
            obj = set_senpix(obj,s,'s');
        end
        %
        function val = get.e(obj)
            val = obj.e_;
        end
        function obj = set.e(obj, e)
            obj = set_senpix(obj,e,'e');
            if any(e<0)
                error('HORACE:DnDBase:invalid_argument',...
                    'errors values can not be negative')
            end
        end
        %
        function val = get.npix(obj)
            val = obj.npix_;
        end
        function obj = set.npix(obj, npix)
            obj = set_senpix(obj,npix,'npix');
            if any(npix<0)
                error('HORACE:DnDBase:invalid_argument',...
                    'npix values can not be negative')
            end

        end
        %
        function ax = get.axes(obj)
            ax = obj.axes_;
        end
        function obj = set.axes(obj,val)
            obj = check_and_set_axes_block_(obj,val);
        end
        %
        function pr = get.proj(obj)
            pr = obj.proj_;
        end
        function obj = set.proj(obj,val)
            if ~isa(val,'aProjection')
                error('HORACE:DnDBase:invalid_argument',...
                    'input for proj property has to be an instance of aProjection class only. It is %s',...
                    class(val));
            end
            check_combo_ = obj.proj_.do_check_combo_arg;
            obj.proj_ = val;
            obj.proj_.do_check_combo_arg = check_combo_;
        end
        function range = get.img_range(obj)
            range = obj.axes_.img_range;
        end
        function nb = get.nbins(obj)
            nb = obj.axes_.data_nbins;
        end
        %------------------------------------------------------------------
        % Serializable interface
        %------------------------------------------------------------------
        function flds = saveableFields(obj)
            flds = obj.fields_to_save_;
        end
        function ver  = classVersion(~)
            ver = 3;
        end

        function obj = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained dnd object. Return the result of the check and the
            % reason for failure.
            %
            obj = check_combo_arg_(obj);
        end
        %
        function struct = to_head_struct(obj,keep_data_arrays)
            %convert dnd data into structure, obtained by head operation
            if nargin == 1
                keep_data_arrays = true;
            end
            struct = to_head_struct_(obj,keep_data_arrays);
        end
    end

    methods(Access = protected)
        wout = unary_op_manager(obj, operation_handle);
        wout = binary_op_manager_single(w1, w2, binary_op);
        [proj, pbin] = get_proj_and_pbin(w) % Retrieve the projection and
        %                              % binning of an sqw or dnd object

        wout = cut_dnd_main (data_source, ndims, varargin);
        %------------------------------------------------------------------
        wout = sqw_eval_nopix(win, sqwfunc, all_bins, pars); % evaluate
        %                              % function on dnd object
        function wout = sqw_eval_pix(~, varargin)
            % Can not evaluate pixels function on a dnd object
            error('HORACE:DnDBase:runtime_error', ...
                'sqw_eval_pix can not be invoked on dnd object');
        end
        function [ok, mess] = equal_to_tol_internal(w1, w2, name_a, name_b, varargin)
            [ok, mess] = equal_to_tol_internal_(w1, w2, name_a, name_b, varargin{:});
        end
        %------------------------------------------------------------------
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
            if numel(inputs)>1
                out = cell(numel(inputs),1);
                for i=1:numel(inputs)
                    out{i} = modify_old_structure_(inputs(i));
                end
                outa = [out{:}];

                out = struct('array_dat',[]);
                out.array_dat = outa;
            else
                out = modify_old_structure_(inputs);
            end

            if isfield(out,'array_dat')
                obj = obj.from_bare_struct(out.array_dat);
            else
                obj = obj.from_bare_struct(out);
            end
        end
        %
        function obj = set_do_check_combo_arg(obj,val)
            % set internal property do_check_combo_arg to all object
            % components, which are serializable
            val = logical(val);
            obj.do_check_combo_arg_ = val;
            obj.axes_.do_check_combo_arg  = val;
            obj.proj_.do_check_combo_arg  = val;
        end
        %
        function obj = set_senpix(obj,val,field)
            % set signal error or npix value to a class field
            if ~isnumeric(val)
                error('HORACE:DnDBase:invalid_argument',...
                    'input %s must be numeric array',field)
            end
            obj.([field,'_']) = val;
            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end
        end

        function varargout = cut_single(obj, tag_proj, targ_axes, outfile, ...
                proj_given,log_level)
            % do single cut from a dnd object
            if nargout > 0
                return_cut = true;
            else
                return_cut = false;
            end
            varargout{1} = cut_single_(obj, tag_proj, targ_axes,...
                return_cut,outfile,proj_given,log_level);
        end

    end
end
