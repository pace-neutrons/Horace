classdef (InferiorClasses = {?d0d, ?d1d, ?d2d, ?d3d, ?d4d}) sqw < SQWDnDBase & sqw_plot_interface

    %SQW Create an sqw object
    %
    % Syntax:
    %   >> w = sqw ()               % Create empty, zero-dimensional SQW object
    %   >> w = sqw (struct)         % Create from a structure with valid fields (internal use)
    %   >> w = sqw (filename)       % Create an sqw object from a file
    %   >> w = sqw (sqw_object)     % Create a new SQW object from a existing one
    %
    properties(Dependent)
        npixels     % common with loaders interface to pix.num_pixels property
        %           % describing number of pixels (neutron events) stored
        %           % in sqw object
        %
        runid_map   % the map which connects header number
        %           % with run_id stored in pixels, e.g. map contains
        %           % connection runid_pixel->header_number

        main_header % Generic information about contributed files
        %           % and the sqw file creation date.
        experiment_info
        detpar
        %
        data; % The information about the N-D neutron image, containing
        %       combined and bin-averaged information about the
        %       neutron experiment.
        %
        pix % access to pixel information, if any such information is
        %     stored within an object. May also return pix_combine_info or
        %     filebased pixels. (TODO -- this should be modified)
        %;
    end
    properties(Hidden,Dependent)
        % obsolete property, duplicating detpar. Do not use
        detpar_x
        % compatibility field, providing old interface for new
        % experiment_info class. Returns array of IX_experiment
        % from Experiment class. Conversion to old header is not performed
        header;
    end
    properties(Access = protected)
        % holder for image data, e.g. appropriate dnd object
        data_;
        % holder for pix data
        pix_ = PixelData()      % Object containing data for each pixe
    end
    properties(Access=private)
        main_header_ = main_header_cl();
        experiment_info_ = Experiment();
        detpar_  = struct([]);
    end
    properties(Constant,Access=protected)
        fields_to_save_ = {'main_header','experiment_info','detpar','data','pix'};
    end

    methods
        has = has_pixels(w);          % returns true if a sqw object has pixels
        write_sqw(obj,sqw_file);      % write sqw object in an sqw file
        wout = smooth(win, varargin)  % smooth sqw object or array of sqw
        %                             % objects containing no pixels
        function [val, n] = data_bin_limits (obj)
            % Get limits of the data in an n-dimensional dataset, that is,
            % find the coordinates along each of the axes of the smallest
            % cuboid that contains bins with non-zero values of
            % contributing pixels.
            %
            % Syntax:
            %   >> [val, n] = data_bin_limits (din)
            %
            [val,n] = obj.data.data_bin_limits();
        end
        % sigvar block
        %------------------------------------------------------------------
        wout = sigvar(w);
        [s,var,mask_null] = sigvar_get (w);
        w = sigvar_set(win, sigvar_obj);
        sz = sigvar_size(w);
        %------------------------------------------------------------------
        wout = cut(obj, varargin); % take cut from the sqw object.
        %
        function wout = cut_dnd(obj,varargin)
            % legacy entrance to cut for dnd objects
            wout = cut(obj.data,varargin{:});
        end        
        function wout = cut_sqw(obj,varargin)
            % legacy entrance to cut for sqw object            
            wout = cut(obj, varargin{:});
        end
        %
        [wout,mask_array] = mask(win, mask_array);
        %
        wout = mask_pixels(win, mask_array);
        wout = mask_random_fraction_pixels(win,npix);
        wout = mask_random_pixels(win,npix);


        %[sel,ok,mess] = mask_points (win, varargin);
        varargout = multifit (varargin);


        % TOBYFIT intreface
        %------------------------------------------------------------------
        %TODO: Something in this interface looks dodgy. Should it be just
        %      TOBYFIT interface, or should it go out of here?
        varargout = tobyfit (varargin);
        [wout,state_out,store_out]=tobyfit_DGdisk_resconv(win,caller,state_in,store_in,...
            sqwfunc,pars,lookup,mc_contributions,mc_points,xtal,modshape);
        [cov_proj, cov_spec, cov_hkle] = tobyfit_DGdisk_resfun_covariance(win, indx);
        [wout,state_out,store_out]=tobyfit_DGfermi_resconv(win,caller,state_in,store_in,...
            sqwfunc,pars,lookup,mc_contributions,mc_points,xtal,modshape);
        [cov_proj, cov_spec, cov_hkle] = tobyfit_DGfermi_resfun_covariance(win, indx);

        %------------------------------------------------------------------
        [ok,mess,varargout] = parse_pixel_indicies (win,indx,iw);

        wout=combine_sqw(w1,w2);
        function wout= rebin(win,varargin)
            wout=rebin_sqw(win,varargin{:});
        end
        wout=rebin_sqw(win,varargin);
        wout=symmetrise_sqw(win,v1,v2,v3);
        [ok,mess,w1tot,w2tot]=is_cut_equal(f1,f2,varargin);
        wtot=combine_cuts(w);
        wout=recompute_bin_data_tester(sqw_obj);
        %
        % return the header, common for all runs (average?)
        [header_ave, ebins_all_same]=header_average(header);
        [alatt,angdeg,ok,mess] = lattice_parameters(win);
        [wout, pars_out] = refine_crystal_strip_pars (win, xtal, pars_in);

        wout = section (win,varargin);

        [d, mess] = make_sqw_from_data(varargin);
        varargout = head(obj,vararin);
        %
        [ok,mess,nd_ref,matching]=dimensions_match(w,nd_ref)
        d=spe(w);
        status = adjust_aspect(w);
        %
        wout = replicate (win,wref);
        varargout = resolution_plot (w, varargin);
        wout = noisify(w,varargin);

        %------------------------------------------------------------------
        % ACCESSORS TO OBJECT PROPERTIES
        function dtp = my_detpar(obj)
            dtp = obj.detpar_x;
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
                obj.data_ = d0d();
                return;
            end
            obj = obj.init(varargin{:});

        end
        %
        function obj = init(obj,varargin)
            % the content of the non-empty constructor, also used to
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
                    obj = from_bare_struct(obj,args.data_struct);
                elseif isfield(args.data_struct,'data')
                    if isfield(args.data_struct.data,'version')
                        obj = serializable.from_struct(args.data_struct);
                    else
                        obj = from_bare_struct(obj,args.data_struct);
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
            if isa(d,'DnDBase') || isempty(d)
                obj.data_ = d;
            else
                error('HORACE:sqw:invalid_argument',...
                    'Only instance of dnd class or empty value may be used as data value. Trying to set up: %s',...
                    class(d))
            end
        end
        %
        function pix = get.pix(obj)
            pix  = obj.pix_;
        end
        function obj = set.pix(obj,val)
            if isa(val,'PixelData') || isa(val,'pix_combine_info')
                obj.pix_ = val;
            elseif isempty(val)
                obj.pix_ = PixelData();
            else
                obj.pix_ = PixelData(val);
            end
        end
        %
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
        %
        function val = get.main_header(obj)
            val = obj.main_header_;
        end
        function obj = set.main_header(obj,val)
            if isempty(val)
                obj.main_header_  = main_header_cl();
                return;
            end
            if isa(val,'main_header_cl')
                obj.main_header_ = val;
            elseif isstruct(val)
                obj.main_header_ = main_header_cl(val);
            else
                error('HORACE:sqw:invald_argument',...
                    'main_header property accepts only inputs with main_header_cl instance class or structure, convertible into this class. You provided %s', ...
                    class(val));
            end
        end
        %
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
        function  save_xye(obj,varargin)
            save_xye(obj.data,varargin{:});
        end
        function  s=xye(w, varargin)
            % Get the bin centres, intensity and error bar for a 1D, 2D, 3D or 4D dataset
            s = w.data.xye(varargin{:});
        end
        function npix = get.npixels(obj)
            npix = obj.pix_.num_pixels;
        end

        function ver  = classVersion(~)
            % define version of the class to store in mat-files
            % and nxsqw data format. Each new version would presumably read
            % the older version, so version substitution is based on this
            % number
            ver = 4;
        end
        function flds = saveableFields(~)
            flds = sqw.fields_to_save_;
        end
        function map = get.runid_map(obj)
            if isempty(obj.experiment_info)
                map = [];
            else
                map = obj.experiment_info.runid_map;
            end
        end
        function [nd,sz] = dimensions(obj)
            % return size and shape of the image arrays
            [nd,sz] = obj(1).data_.dimensions();
        end
        function str = saveobj(obj)
            if ~obj.main_header_.creation_date_defined
                % support old files, which do not have creation date defined
                obj.main_header_.creation_date = datetime('now');
            end
            str = saveobj@serializable(obj);
        end
        function is = dnd_type(obj)
            is = isempty(obj.pix_);
        end
    end

    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class
            obj = sqw();
            obj = loadobj@serializable(S,obj);
        end
    end

    methods(Access = protected)
        wout = unary_op_manager(obj, operation_handle);
        wout = binary_op_manager_single(w1, w2, binary_op);
        wout = recompute_bin_data(w);
        [proj, pbin] = get_proj_and_pbin(w) % Retrieve the projection and
        %                              % binning of an sqw or dnd object


        wout = sqw_eval_(wout, sqwfunc, ave_pix, all_bins, pars);
        wout = sqw_eval_pix(w, sqwfunc, ave_pix, pars, outfilecell, i);

        function  [ok, mess] = equal_to_tol_internal(w1, w2, name_a, name_b, varargin)
            [ok, mess] = equal_to_tol_internal_(w1, w2, name_a, name_b, varargin{:});
        end

        function obj = from_old_struct(obj,S)
            % restore object from the old structure, which describes the
            % previous version(s) of the object.
            %
            % The method is called by loadobj in the case if the input
            % structure does not contain version or the version, stored
            % in the structure does not correspond to the current version
            %
            % Input:
            % ------
            %   S       An instance of this object or struct
            % By default, this function interfaces the default from_bare_struct
            % method, but when the old structure substantially differs from
            % the modern structure, this method needs the specific overloading
            % to allow loadob to recover new structure from an old structure.
            %
            obj = set_from_old_struct_(obj,S);
        end
    end
    %----------------------------------------------------------------------
    methods(Static, Access = private)
        % Signatures of private class functions declared in files
        sqw_struct = make_sqw(ndims);
        detpar_struct = make_sqw_detpar();
        header = make_sqw_header();
    end
    %----------------------------------------------------------------------
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
            obj = from_bare_struct(obj,lds);
        end
        function ld_str = get_loader_struct_(~,ldr,pixel_page_size)
            % load sqw structure, using file loader
            ld_str = struct();

            [ld_str.main_header, ld_str.experiment_info, ld_str.detpar,...
                ld_str.data,ld_str.pix] = ...
                ldr.get_sqw('-legacy','-noupgrade', 'pixel_page_size', pixel_page_size);
        end
        function obj = init_from_loader_struct_(obj, data_struct)
            % initialize object contents using structure, obtained from
            % file loader
            obj.main_header = data_struct.main_header;
            obj.header = data_struct.header;
            obj.detpar = data_struct.detpar;
            obj.data = data_struct.data;
            obj.pix = data_struct.pix;
        end
    end
end
