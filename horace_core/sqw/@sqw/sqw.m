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
        % common with loaders interface to pix.num_pixels property
        % describing number of pixels (neutron events) stored
        % in sqw object
        npixels;

        % the map which connects header number
        % with run_id stored in pixels, e.g. map contains
        % connection runid_pixel->header_number
        runid_map;

        % Generic information about contributed files
        % and the sqw file creation date.
        main_header;

        detpar;

        experiment_info;
        % The information about the N-D neutron image, containing
        % combined and bin-averaged information about the
        % neutron experiment.
        data;

        % access to pixel information, if any such information is
        % stored within an object. May also contain pix_combine_info or
        % filebased pixels.
        pix;

        % The date of the sqw object file creation. As the date is defined both
        % in sqw and dnd object parts, this property synchronize both
        creation_date;
        % return state of the object, if it is fully in memory or
        % filebacked
        is_filebacked;
    end

    properties(Hidden,Dependent)
        % the same as npixels, but allows to use the same interface on sqw
        % object or pixels
        num_pixels;
        % obsolete property, duplicating detpar. Do not use
        detpar_x;

        % compatibility field, providing old interface for new
        % experiment_info class. Returns array of IX_experiment
        % from Experiment class. Conversion to old header is not performed
        header;

        % the name of the file, used to store sqw first time
        full_filename;
        % Holder for the class, which would delete temporary file - source
        % of file-backed sqw object on object deletion. Always empty
        % for memory-based sqw objects or objects, build from permanent sqw
        % files.
        tmp_file_holder;
    end

    properties(Access=protected)
        % holder for image data, e.g. appropriate dnd object
        data_;

        % holder for pix data
        % Object containing data for each pixe
        pix_ = PixelDataBase.create();
    end

    properties(Hidden)
    end

    properties(Access=protected)
        main_header_ = main_header_cl();
        experiment_info_ = Experiment();
        detpar_  = struct([]);
    end

    methods(Static)
        function form_fields = head_form(sqw_only,keep_data_arrays)
            % the method returns list of fields, which need to be filled by
            % head function
            %
            %
            form_fields = {'nfiles','npixels','data_range','creation_date'};
            sqw_only = exist('sqw_only', 'var') && sqw_only;
            keep_data_arrays = exist('keep_data_arrays', 'var') && keep_data_arrays;

            if sqw_only
                return
            end

            [dnd_fields,data_fields] = DnDBase.head_form(false);
            if keep_data_arrays
                form_fields   = [dnd_fields(1:end-1)';form_fields(:);data_fields(:)];
            else
                form_fields   = [dnd_fields(1:end-1)';form_fields(:)];
            end
        end
    end

    %======================================================================
    % Various sqw methods
    methods
        has = has_pixels(w);          % returns true if a sqw object has pixels
        write_sqw(obj,sqw_file);      % write sqw object in an sqw file
        % sigvar block
        %------------------------------------------------------------------
        w = sigvar_set(win, sigvar_obj);
        %------------------------------------------------------------------
        wout = cut(obj, varargin); % take cut from the sqw object.

        function wout = cut_sqw(obj,varargin)
            % legacy entrance to cut for sqw object
            wout = cut(obj, varargin{:});
        end

        [wout,mask_array] = mask(win, mask_array);

        wout = mask_pixels(win, mask_array,varargin);
        wout = mask_random_fraction_pixels(win,npix);
        wout = mask_random_pixels(win,npix);


        %[sel,ok,mess] = mask_points (win, varargin);
        varargout = multifit (varargin);

        %------------------------------------------------------------------
        [ok,mess,varargout] = parse_pixel_indices (win,indx,iw);

        wout=combine_sqw(w1,w2);
        function wout= rebin(win,varargin)
            wout=rebin_sqw(win,varargin{:});
        end
        wout=rebin_sqw(win,varargin);
        wout=symmetrise_sqw(win,v1,v2,v3);
        wout=recompute_bin_data(sqw_obj,out_file_name);

        % return the header, common for all runs (average?)
        [header_ave, ebins_all_same]=header_average(header);
        [alatt,angdeg,ok,mess] = lattice_parameters(win);
        [wout, pars_out] = refine_crystal_strip_pars (win, xtal, pars_in);

        wout = section (win,varargin);

        [d, mess] = make_sqw_from_data(varargin);
        varargout = head(obj,vararin);

        [ok,mess,nd_ref,matching]=dimensions_match(w,nd_ref)
        d=spe(w);

        wout = replicate (win,wref);
        varargout = resolution_plot (w, varargin);
        wout = noisify(w,varargin);
        %----------------------------------
        % Replace the sqw's signal and variance data with coordinate values (see below)
        w = coordinates_calc(w, name)

        new_sqw = copy(obj, varargin)
        [obj, ldr] = get_new_handle(obj, outfile)
        wh   = get_write_handle(obj, outfile)
        obj = finish_dump(obj,varargin);
    end
    %======================================================================
    % METHODS, Available on SQW but redirecting actions to DnD and requesting
    % only DND object for implementation.
    methods
        function [nd,sz] = dimensions(win)
            % Return size and shape of the image
            % arrays in sqw or dnd object
            [nd,sz] = win(1).data.dimensions();
        end
        %
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

        % smooth sqw object or array of sqw
        % objects containing no pixels
        wout = smooth(win, varargin)
        %
        function wout = cut_dnd(obj,varargin)
            % legacy entrance to cut for dnd objects
            wout = cut(obj.data,varargin{:});
        end
        %------------------------------------------------------------------
        % sigvar block
        wout              = sigvar(w); % Create sigvar object from sqw object
        [s,var,mask_null] = sigvar_get (w);
        sz                = sigvar_size(w);
        %------------------------------------------------------------------
        % titles used when plotting an sqw object
        function [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] =...
                data_plot_titles(obj)
            % get titles used to display sqw object
            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
                obj.data.data_plot_titles();
        end
        %------------------------------------------------------------------
        % construct dataset from appropriately sized dnd part of an object
        wout = IX_dataset_1d(w);
        wout = IX_dataset_2d(w);
        wout = IX_dataset_3d(w);
        %
        function range = targ_range(obj,targ_proj,varargin)
            % calculate the maximal range of the image may be produced by
            % target projection applied to the current image.
            range = obj.data.targ_range(targ_proj,varargin{:});
        end
        function status = adjust_aspect(obj)
            % method reports if the plotting operation should adjust
            % aspect ratio when plotting sqw objects
            status  = obj.data.adjust_aspect();
        end
        function [targ_ax_block,targ_proj] = define_target_axes_block(w, targ_proj, pbin, sym)
            % define target axes from existing axes, inputs and the target projections
            % Inputs:
            %  w        -- sqw object
            % targ_proj -- the projection class which defines the
            %              coordinate system of the cut
            % pbin      -- bining parameters of the cut
            %
            % sym       -- Symmetry operations to apply to block
            %
            % Retugns:
            % targ_axes_block
            %           -- the axes block which corresponds to the target
            %              projection and have binning defined by pbin
            %              parameter
            % targ_proj
            %           -- the input target projection, which extracted
            %              some input parameters from source projection
            %              (e.g. lattice if undefined, etc)
            [targ_ax_block, targ_proj] = w.data_.define_target_axes_block(targ_proj, pbin, sym);
        end
        function qw=calculate_qw_bins(win,varargin)
            % Calculate qh,qk,ql,en for the centres of the bins of an
            % n-dimensional sqw dataset
            qw = win.data.calculate_qw_bins(varargin{:});
        end
        function [q,en]=calculate_q_bins(win)
            [q,en] = win.data.calculate_q_bins();
        end
    end
    %======================================================================
    % ACCESSORS TO OBJECT PROPERTIES and construction
    methods
        function obj = sqw(varargin)
            obj = obj@SQWDnDBase();

            if nargin==0 % various serializers need empty constructor
                obj.data_ = d0d();
                return;
            end
            obj = obj.init(varargin{:});
        end

        function obj = init(obj,varargin)
            % the content of the non-empty constructor, also used to
            % initialize empty instance of the object
            %
            % here we go through the various options for what can
            % initialise an sqw object
            arg_struc = sqw.parse_sqw_args(varargin{:});

            % i) copy - it is an sqw
            if ~isempty(arg_struc.sqw_obj)
                obj = copy(arg_struc.sqw_obj);
                % ii) filename - init from a file or file accessor
            elseif ~isempty(arg_struc.file)
                obj = obj.init_from_file(arg_struc);
                % iii) struct a struct, pass to the struct
                % loader
            elseif ~isempty(arg_struc.data_struct)
                if isfield(arg_struc.data_struct,'data')
                    if isfield(arg_struc.data_struct.data,'version')
                        obj = serializable.from_struct(arg_struc.data_struct);
                    else
                        obj = from_bare_struct(obj,arg_struc.data_struct);
                    end
                else
                    error('HORACE:sqw:invalid_argument',...
                        'Unidentified input data structure %s', ...
                        disp2str(arg_struc.data_struct));
                end
            end
        end
        %------------------------------------------------------------------
        % Public getters/setters expose all wrapped data attributes
        function val = get.data(obj)
            val = obj.data_;
        end

        function obj = set.data(obj, d)
            if isa(d,'DnDBase')
                obj.data_ = d;
            elseif isempty(d)
                obj.data_ = d0d();
            else
                error('HORACE:sqw:invalid_argument',...
                    'Only instance of dnd class or empty value may be used as data value. Trying to set up: %s',...
                    class(d))
            end
        end

        function pix = get.pix(obj)
            pix  = obj.pix_;
        end

        function obj = set.pix(obj,val)
            if isa(val, 'PixelDataBase') || isa(val,'pix_combine_info')
                obj.pix_ = val;
            elseif isempty(val)
                %  necessary for clearing up the memmapfile, (if any)
                obj.pix_ = PixelDataMemory();
            else
                obj.pix_ = PixelDataBase.create(val);
            end
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
            if isempty(val)
                obj.main_header_  = main_header_cl();
            elseif isa(val,'main_header_cl')
                obj.main_header_ = val;
            elseif isstruct(val)
                obj.main_header_ = main_header_cl(val);
            else
                error('HORACE:sqw:invalid_argument',...
                    'main_header property accepts only inputs with main_header_cl instance class or structure, convertible into this class. You provided %s', ...
                    class(val));
            end
            if ~isempty(obj.experiment_info_) && obj.experiment_info_.n_runs>0 && ...
                    obj.experiment_info_.n_runs ~= obj.main_header_.nfiles
                warning('HORACE:inconsitent_sqw', ...
                    'number of rund defined in experiment_info (%d) is not equal to number of contributing files, defined in main sqw header (%d)', ...
                    obj.experiment_info_.n_runs,obj.main_header_.nfiles);
            end
        end

        function val = get.experiment_info(obj)
            val = obj.experiment_info_;
        end

        function obj = set.experiment_info(obj,val)
            if isempty(val)
                obj.experiment_info_ = Experiment();
            elseif isa(val,'Experiment')
                obj.experiment_info_ = val;
            else
                error('HORACE:sqw:invalid_argument',...
                    'Experiment info can be only instance of Experiment class, actually it is %s',...
                    class(val));
            end
            obj.main_header_.nfiles = obj.experiment_info_.n_runs;
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
        function npix = get.num_pixels(obj)
            npix = obj.pix_.num_pixels;
        end


        function map = get.runid_map(obj)
            if isempty(obj.experiment_info)
                map = [];
            else
                map = obj.experiment_info.runid_map;
            end
        end

        function is = dnd_type(obj)
            is = obj.pix_.num_pixels == 0;
        end
        %
        function fn = get.full_filename(obj)
            if obj.has_pixels
                fn = obj.pix.full_filename;
            else
                fn = fullfile(obj.main_header.filepath,obj.main_header.filename);
            end
        end
        function obj = set.full_filename(obj,val)
            if ~(isstring(val)||ischar(val))
                error('HORACE:sqw:invalid_argument', ...
                    ' Full filename can be only string, describing input file together with the path to this file. It is: %s', ...
                    disp2str(val));
            end
            [fp,fn,fex]= fileparts(val);
            obj.main_header.filename = [fn,fex];
            obj.main_header.filepath = fp;
            obj.data.filename = [fn,fex];
            obj.data.filepath = fp;
            obj.pix.full_filename = val;
        end
        %
        function cd = get.creation_date(obj)
            cd = obj.main_header.creation_date;
        end
        function obj = set.creation_date(obj,val)
            obj.main_header.creation_date = val;
            obj.data.creation_date = val;
        end
        %
        function is = get.is_filebacked(obj)
            if obj.has_pixels
                is = obj.pix.is_filebacked;
            else
                is = false;
            end
        end
        function holder = get.tmp_file_holder(obj)
            if isempty(obj.pix) || ~obj.pix.is_filebacked
                holder = [];
                return;
            end
            holder = obj.pix.tmp_file_holder;
        end
        function obj = set.tmp_file_holder(obj,val)
            if isempty(obj.pix) || ~obj.pix.is_filebacked
                return;
            end
            obj.pix.tmp_file_holder = val;
        end

        %==================================================================
        function obj = apply_c(obj, operation)
            % Apply special PageOp operation affecting sqw object and pixels
            %
            % See what PageOp is from PageOpBase class description and its
            % children
            %
            % Inputs:
            % obj       -- sqw object - contains pixels and image to be
            %              modified
            % operation -- valid PageOpBase subclass containing function
            %              which operates on PixelData, modifies pixels and
            %              calculates changes to image, caused by the
            %              modifications to pixels.
            for i=1:numel(obj)
                obj(i) = obj(i).pix.apply_c(obj(i),operation);
            end
        end

        function obj = apply(obj, func_handle, args, recompute_bins, compute_variance)
            if ~exist('args', 'var')
                args = {};
            end
            if ~exist('recompute_bins', 'var')
                recompute_bins = true;
            end
            if ~exist('compute_variance', 'var')
                compute_variance = false;
            end

            if recompute_bins
                [obj.pix, obj.data] = obj.pix.apply(func_handle, args, obj.data, compute_variance);
            else
                obj.pix = obj.pix.apply(func_handle, args);
            end
        end
    end
    %======================================================================
    % REDUNDANT and compatibility ACCESSORS
    methods
        function obj = change_header(obj,hdr)
            if obj.experiment_info.n_runs ~= hdr.n_runs
                error('HORACE:sqw:invalid_argument', ...
                    'Existing experiment info describes %d runs and new experiment info describes %d runs. N-runs have to be the same', ...
                    obj.experiment_info.n_runs,hdr.n_runs)
            end
            obj.experiment_info = hdr;
        end

        function obj = change_detpar(obj,dtp)
            obj.detpar_x = dtp;
        end

        function val = get.detpar_x(obj)
            % obsolete interface
            val = obj.detpar_;
        end

        function obj = set.detpar_x(obj,val)
            % obsolete interface
            obj.detpar_ = val;
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

    end

    %======================================================================
    % TOBYFIT INTERFACE
    methods
        % set the moderator pulse model and its parameters. (TODO: should
        % be setting a class. Ticket #910)
        obj = set_mod_pulse(obj,pulse_model,pmp)
        % Get moderator pulse model name and mean pulse parameters for
        % an array of sqw objects
        [pulse_model,pp,ok,mess,p,present] = get_mod_pulse(varargin)

        % add or reset instrument, related to this sqw object
        obj = set_instrument(obj, instrument,varargin)
        function inst = get_instruments(obj,varargin)
            % retrieve object container with instruments
            inst = obj.experiment_info.instruments;
        end
        % Return the mean fixed neutron energy and emode for an array of sqw objects.
        [efix,emode,ok,mess,en] = get_efix(obj,tol);
        % Set the fixed neutron energy for an array of sqw objects.
        obj = set_efix(obj,efix,emode);
        %------------------------------------------------------------------
        % Change the crystal lattice and orientation of an sqw object or
        % array of objects to apply alignment corrections
        wout = change_crystal (obj,alignment_info,varargin)
        % modify crystal lattice and orientation matrix to remove legacy
        % alignment.
        [wout,al_info] = remove_legacy_alignment(obj,varargin)
        % remove legacy alignment and put modern alignment instead
        [wout,al_info] = upgrade_legacy_alignment(obj,varargin)
        %------------------------------------------------------------------
        %TODO: Special call on interface for different type of instruments
        %      from generic object, which may contain any instrument is
        %      incorrect. It should be resfun covariance here, if it is needs
        %      to be here at all.
        varargout = tobyfit (varargin);
        [wout,state_out,store_out]=tobyfit_DGdisk_resconv(win,caller,state_in,store_in,...
            sqwfunc,pars,lookup,mc_contributions,mc_points,xtal,modshape);
        [cov_proj, cov_spec, cov_hkle] = tobyfit_DGdisk_resfun_covariance(win, indx);
        [wout,state_out,store_out]=tobyfit_DGfermi_resconv(win,caller,state_in,store_in,...
            sqwfunc,pars,lookup,mc_contributions,mc_points,xtal,modshape);
        [cov_proj, cov_spec, cov_hkle] = tobyfit_DGfermi_resfun_covariance(win, indx);
    end

    %======================================================================
    methods(Access = protected)
        wout = binary_op_manager_single(w1, w2, binary_op);
        [proj, pbin] = get_proj_and_pbin(w) % Retrieve the projection and
        % binning of an sqw or dnd object


        wout = sqw_eval_(wout, sqwfunc, ave_pix, all_bins, pars);
        wout = sqw_eval_pix(w, sqwfunc, ave_pix, pars, outfilecell, i);

        function  [ok, mess] = equal_to_tol_internal(w1, w2, name_a, name_b, varargin)
            % compare two sqw objects according to internal comparison
            % algorithm
            [ok, mess] = equal_to_tol_internal_(w1, w2, name_a, name_b, varargin{:});
        end
        function obj = init_from_file(obj, in_struc)
            % Initialize SQW from file or file accessor
            obj = init_sqw_from_file_(obj, in_struc);
        end
    end
    methods(Static,Access=protected)
        function arg = parse_sqw_args(varargin)
            % process various inputs for the constructor or init function
            % and return some standard output used in sqw construction or
            % initialization
            arg = parse_sqw_args_(varargin{:});
        end
    end
    %----------------------------------------------------------------------
    methods(Static, Access=private)
        % Signatures of private class functions declared in files
        sqw_struct = make_sqw(ndims);
        detpar_struct = make_sqw_detpar();
        header = make_sqw_header();

        function ld_str = get_loader_struct_(ldr, file_backed)
            % load sqw structure, using file loader
            ld_str = struct();

            [ld_str.main_header, ld_str.experiment_info, ld_str.detpar,...
                ld_str.data,ld_str.pix] = ...
                ldr.get_sqw('-legacy','-noupgrade', ...
                'file_backed', file_backed);
        end
    end
    %----------------------------------------------------------------------
    methods(Access=private)
        function  [set_single,set_per_obj,n_runs_in_obj]=find_set_mode(obj,varargin)
            % Helper function for various set component for Tobyfit methods
            % Given array of values to set on array of objects, identify how these
            % values should be distributed among objects
            [set_single,set_per_obj,n_runs_in_obj]=find_set_mode_(obj,varargin{:});
        end
    end

    %======================================================================
    % SERIALIZABLE INTERFACE
    properties(Constant,Access=protected)
        fields_to_save_ = {'main_header','experiment_info','detpar','data','pix'};
    end
    %
    methods
        function ver  = classVersion(~)
            % define version of the class to store in mat-files
            % and nxsqw data format. Each new version would presumably read
            % the older version, so version substitution is based on this
            % number
            ver = 5;
            % version 5 -- support for loading previous version
            % data and setting ub_inv_legacy matrix in case if the data
            % were realigned
        end

        function flds = saveableFields(~)
            flds = sqw.fields_to_save_;
        end

        function str = saveobj(obj)
            if ~obj.main_header_.creation_date_defined
                % support old files, which do not have creation date defined
                obj.main_header_.creation_date = datetime('now');
            end
            str = saveobj@serializable(obj);
        end

        function obj = check_combo_arg(obj)
            % Deals with input of old-style objects where detpar is defined
            % but the detector arrays in experiment_info are empty
            %
            % NB combined if-expression is in parentheses to help visually
            % locate it - just useful cosmetic

            if (~isempty(obj.detpar)                             && ...
                    IX_detector_array.check_detpar_parms(obj.detpar) && ...
                    ~isempty(obj.detpar.group)                       && ...
                    obj.experiment_info.detector_arrays.n_runs == 0     ...
                    )

                n_runs = obj.experiment_info.n_runs;
                detector = IX_detector_array(obj.detpar);
                updated_detectors = obj.experiment_info.detector_arrays;
                %for i=1:n_runs
                updated_detectors = updated_detectors.add_copies_(detector, n_runs);
                %end
                obj.experiment_info.detector_arrays = updated_detectors;
            end
        end
    end

    methods(Access = protected)
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
    %
    methods(Static)
        function obj = loadobj(S)
            % loadobj method, calling generic method of
            % saveable class. Provides empty sqw class instance to set up
            % the data on
            obj = sqw();
            obj = loadobj@serializable(S,obj);
        end
    end
    %======================================================================
    methods(Static, Hidden)
        % Generate special sqw object with given properties. Used in tests.
        out = generate_cube_sqw(shape,varargin)
    end
end
