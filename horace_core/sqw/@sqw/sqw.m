classdef (InferiorClasses = {?d0d, ?d1d, ?d2d, ?d3d, ?d4d}) sqw < SQWDnDBase & serializable
    %SQW Create an sqw object
    %
    % Syntax:
    %   >> w = sqw ()               % Create empty, zero-dimensional SQW object
    %   >> w = sqw (struct)         % Create from a structure with valid fields (internal use)
    %   >> w = sqw (filename)       % Create an sqw object from a file
    %   >> w = sqw (sqw_object)     % Create a new SQW object from a existing one
    
    properties(Dependent)
        % the
        main_header
        experiment_info
        detpar
        data;
        %;
    end
    properties(Hidden,Dependent)
        % obsolete property, duplicating detpar. Do not use
        detpar_x
        % compartibility field, providing old interface for new
        % experiment_info class. Returns array of IX_experiment
        % from Experiment class. Conversion to old header is not performed
        header;
    end
    
    properties(Access=private)
        main_header_ = struct([]);
        experiment_info_ = Experiment();
        detpar_  = struct([]);
    end
    properties(Constant,Access=private)
        fields_to_save_ = {'main_header','experiment_info','detpar','data'};
    end
    
    methods
        function ver  = classVersion(~)
            % define version of the class to store in mat-files
            % and nxsqw data format. Each new version would presumably read
            % the older version, so version substitution is based on this
            % number
            ver = 1;
        end
        function flds = indepFields(~)
            flds = sqw.fields_to_save_;
        end
        
        
        wout = sigvar(w);
        w = sigvar_set(win, sigvar_obj);
        sz = sigvar_size(w);
        %[sel,ok,mess] = mask_points (win, varargin);
        varargout = multifit (varargin);
        
        varargout = tobyfit (varargin);
        [wout,state_out,store_out]=tobyfit_DGdisk_resconv(win,caller,state_in,store_in,...
            sqwfunc,pars,lookup,mc_contributions,mc_points,xtal,modshape);
        [cov_proj, cov_spec, cov_hkle] = tobyfit_DGdisk_resfun_covariance(win, indx);
        [wout,state_out,store_out]=tobyfit_DGfermi_resconv(win,caller,state_in,store_in,...
            sqwfunc,pars,lookup,mc_contributions,mc_points,xtal,modshape);
        [cov_proj, cov_spec, cov_hkle] = tobyfit_DGfermi_resfun_covariance(win, indx);
        [ok,mess,varargout] = parse_pixel_indicies (win,indx,iw);
        wout=combine_sqw(w1,w2);
        
        wout=rebin_sqw(win,varargin);
        wout=symmetrise_sqw(win,v1,v2,v3);
        [ok,mess,w1tot,w2tot]=is_cut_equal(f1,f2,varargin);
        wtot=combine_cuts(w);
        wout=recompute_bin_data_tester(sqw_obj);
        wout = dnd (win);
        %
        % return the header, common for all runs (average?)
        [header_ave, ebins_all_same]=header_average(header);
        [alatt,angdeg,ok,mess] = lattice_parameters(win);
        [wout, pars_out] = refine_crystal_strip_pars (win, xtal, pars_in);
        img_range = recompute_img_range(w);
        
        wout = section (win,varargin);
        [sqw_type, ndims, nfiles, filename, mess,ld] = is_sqw_type_file(w,infile);
        [d, mess] = make_sqw_from_data(varargin);
        varargout = head (varargin);
        d=spe(w);
        %{
        %[deps,eps_lo,eps_hi,ne]=energy_transfer_info(header);
        %}
        status = adjust_aspect(w);
        varargout = resolution_plot (w, varargin);
        wout = noisify(w,varargin);
        
        function dtp = my_detpar(obj)
            if ~isempty(obj.detpar_x)
                dtp = obj.detpar_x;
            elseif ~isempty(obj.experiment_info.detector_arrays)
                dtp = obj.experiment_info.detector_arrays(1).convert_to_old_detpar();
            end
        end
        
        function obj = change_detpar(obj,dtp)
            obj.detpar_x = dtp;
        end
        
        %function hdr = my_header(obj)
        %    hdr = obj.experiment_info;
        %end
        
        function obj = change_header(obj,hdr)
            obj.experiment_info = hdr;
        end
        
        function obj = sqw(varargin)
            obj = obj@SQWDnDBase();
            
            if nargin==0 % various serializers need empty constructor
                return;
            end
            obj = init(obj,varargin{:});
            
        end
        function obj = init(obj,varargin)
            % the content of the non-empty coustructor, also used to
            % initialize empty instance of the object
            %
            % here we go through the various options for what can
            % initialise an sqw object
            args = parse_sqw_args_(obj,varargin{:});
            
            % i) copy - it is an sqw
            if ~isempty(args.sqw_obj)
                obj = copy(args.sqw_obj);
                
                % ii) filename - init from a file
            elseif ~isempty(args.filename)
                obj = obj.init_from_file_(args.filename, args.pixel_page_size);
                
                % iii) struct or data loader - a struct, pass to the struct
                % loader
            elseif ~isempty(args.data_struct)
                if isa(args.data_struct,'dnd_file_interface')
                    args.data_struct = obj.get_loader_struct_(...
                        args.data_struct,args.pixel_page_size);
                    obj = from_class_struct(obj,args.data_struct);
                elseif isfield(args.data_struct,'data')
                    if isfield(args.data_struct.data,'version')
                        obj = sqw.loadobj(args.data_struct);
                    elseif isfield(args.data_struct.data,'serial_name')
                        obj = serializable.from_struct(args.data_struct);
                    else
                        obj = from_class_struct(obj,args.data_struct);
                    end
                else
                    error('HORACE:sqw:invalid_argument',...
                        'Unidentified input data structure');
                end
                
            end
        end
        
        % Public getters/setters expose all wrapped data attributes
        function val = get.data(obj)
            val = obj.data_;
        end
        function obj = set.data(obj, d)
            if isa(d,'data_sqw_dnd') || isempty(d)
                obj.data_ = d;
            else
                error('HORACE:sqw:invalid_argument',...
                    'Only data_sqw_dnd class or empty value may be used as data value. Trying to set up: %s',...
                    class(d))
            end
        end
        function hdr = get.header(obj)
            % return old (legacy) header(s) providing short experiment info
            %
            if isempty(obj.experiment_info_)
                hdr = IX_experiment().to_bare_struct();
                hdr.alatt = [];
                hdr.angdeg = [];
                return;
            end
            hdr = obj.experiment_info_.convert_to_old_headers();
            hdr = [hdr{:}];
            hdr = rmfield(hdr,{'instrument','sample'});
        end
        function val = get.detpar(obj)
            val = obj.detpar_;
        end
        function obj = set.detpar(obj,val)
            %TODO: implement checks for validity
            obj.detpar_ = val;
        end
        
        function val = get.main_header(obj)
            val = obj.main_header_;
        end
        function obj = set.main_header(obj,val)
            %TODO: implement checks for validity
            obj.main_header_ = val;
        end
        
        function val = get.experiment_info(obj)
            val = obj.experiment_info_;
        end
        function obj = set.experiment_info(obj,val)
            if isempty(val)
                obj.experiment_info_ = Experiment();
                return;
            elseif ~isa(val,'Experiment')
                error('HORACE:sqw:invalid_argument',...
                    'Experiment info can be only instance of Experiment class, actually it is %s',...
                    class(val));
            end
            obj.experiment_info_ = val;
        end
        
        function val = get.detpar_x(obj)
            % obsolete interface
            val = obj.detpar_;
        end
        function obj = set.detpar_x(obj,val)
            % obsolete interface
            obj.detpar_ = val;
        end
        %        function  save_xye(obj,varargin)
        %            %TODO: Enable this when doing #730
        %            % save data in xye format
        %            save_xye@DnDBase(obj.data,varargin{:});
        %        end
        
    end
    
    methods(Static)
        function obj = loadobj(S)
            % modified boilerplate loadobj method, calling generic method of
            % saveable class
            % the generic code is preceded by the conversion of old-style
            % detpar info into the new detector arrays. This allows loading
            % of .mat files without converting them on disk..
            if isfield(S,'experiment_info') && isfield(S,'detpar')
                if ~isempty(S.detpar) && isempty(S.experiment_info.detector_arrays)
                    dd = IX_detector_array(S.detpar);
                    S.experiment_info.detector_arrays = IX_detector_array.empty;
                    S.experiment_info.detector_arrays(end+1) = dd;
                    S.detpar = struct([]);
                end
            end
            obj = sqw();
            obj = loadobj@serializable(S,obj);
        end
    end
    
    methods(Access = protected)
        wout = unary_op_manager(obj, operation_handle);
        wout = binary_op_manager_single(w1, w2, binary_op);
        [ok, mess] = equal_to_tol_internal(w1, w2, name_a, name_b, varargin);
        
        wout = sqw_eval_(wout, sqwfunc, ave_pix, all_bins, pars);
        wout = sqw_eval_pix_(w, sqwfunc, ave_pix, pars, outfilecell, i);
        
        % take the inputs for a cut and return them in a standard form
        [proj, pbin, opt,args] = process_and_validate_cut_inputs(obj, ndims_source, return_cut, varargin);
        function obj = from_old_struct(obj,S)
            % restore object from the old structure, which describes the
            % previous version of the object.
            %
            % The method is called by loadobj in the case if the input
            % structure does not contain version or the version, stored
            % in the structure does not correspond to the current version
            %
            % By default, this function interfaces the default from_class_struct
            % method, but when the old strucure substantially differs from
            % the moden structure, this method needs the specific overloading
            % to allow loadob to recover new structure from an old structure.
            %
            if ~isfield(S,'version')
                % previous version did not store any version data
                if numel(S)>1
                    tmp = sqw();
                    obj = repmat(tmp, size(S));
                end
                for i = 1:numel(S)
                    ss =S(i);
                    if isfield(ss,'header')
                        if isa(ss.header,'Experiment')
                            ss.experiment_info = ss.header;
                        else
                            ss.experiment_info = Experiment(ss.header);
                        end
                        ss = rmfield(ss,'header');
                    end
                    
                    % assuming that detpar exists and is not empty, convert
                    % its contents into a detector array. There are test
                    % datasets with empty detpar and those should be left
                    % unconverted, they seem to be testing other items in
                    % the sqw and ignoring the detpar.
                    if isfield(ss,'experiment_info') && isfield(ss,'detpar') && ~isempty(ss.detpar)
                        dd = IX_detector_array(ss.detpar);
                        ss.experiment_info.detector_arrays(end+1) = dd;
                        ss = rmfield(ss,'detpar');
                    end
                    
                    if isfield(ss,'data_')
                        ss.data = ss.data_;
                        ss = rmfield(ss,'data_');
                    end
                    
                    obj(i) = sqw(ss);
                end
                return
            end
            if isfield(inputs,'array_dat')
                obj = obj.from_class_struct(inputs.array_dat);
            else
                obj = obj.from_class_struct(inputs);
            end
        end
        
    end
    
    
    methods(Static, Access = private)
        % Signatures of private functions declared in files
        sqw_struct = make_sqw(ndims);
        detpar_struct = make_sqw_detpar();
        header = make_sqw_header();
        main_header = make_sqw_main_header();
        
    end
    
    methods(Access = 'private')
        % process various inputs for the constructor and return some
        % standard output used in sqw construction
        args = parse_sqw_args_(obj,varargin)
        
        function obj = init_from_file_(obj, in_filename, pixel_page_size)
            % Parse SQW from file
            %
            % An error is raised if the data file is identified not a SQW object
            ldr = sqw_formats_factory.instance().get_loader(in_filename);
            if ~strcmpi(ldr.data_type, 'a') % not a valid sqw-type structure
                error('HORACE:sqw:invalid_argument',...
                    'Data file: %s does not contain valid sqw-type object',...
                    in_filename);
            end
            lds = obj.get_loader_struct_(ldr,pixel_page_size);
            obj = sqw();
            obj = from_class_struct(obj,lds);
        end
        function ld_str = get_loader_struct_(~,ldr,pixel_page_size)
            % load sqw structure, using file loader
            ld_str = struct();
            [ld_str.main_header, old_header, ld_str.detpar, ld_str.data] = ...
                ldr.get_sqw('-legacy', 'pixel_page_size', pixel_page_size);
            ld_str.experiment_info = Experiment(old_header);
        end
        %
    end
end
