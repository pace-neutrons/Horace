classdef (InferiorClasses = {?DnDBase,?PixelDataBase,?IX_dataset,?sigvar}) sqw < ...
        SQWDnDBase & sqw_plot_interface
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
        % stored within an object. May also contain MultipxBase class
        % or filebacked pixels.
        pix;

        % The date of the sqw object file creation. As the date is defined both
        % in sqw and dnd object parts, this property synchronize both
        creation_date;
    end

    properties(Dependent,Hidden=true)
        %exposes number of dimensions in the underlying image
        NUM_DIMS;
        % the same as npixels, but allows to use the same interface on sqw
        % object or pixels
        num_pixels;

        % compatibility field, providing old interface for new
        % experiment_info class. Returns array of IX_experiment
        % from Experiment class. Conversion to old header is not performed
        header;

        % the name of the file, used to keep original sqw object or file
        % or the name of the file, backing a filebacked object
        full_filename;
        % True if sqw object is temporary object, deleted on going out of
        % scope.
        is_tmp_obj
    end

    properties(Access=protected)
        % The class providing brief description of a whole sqw file.
        main_header_ = main_header_cl();

        experiment_info_ = Experiment();
        % detectors array
        detpar_  = struct([]);

        % holder for image data, e.g. appropriate dnd object
        data_;

        % holder for pix data
        % Object containing data for each pixel recorded in experiment.
        pix_ = PixelDataBase.create();
    end
    %
    properties(Access=private)
        % holder for the class, which deletes temporary file when holding
        % object goes out of scope.
        % Has to be present on sqw level, as its copy on pix level can not
        % delete sqw file due to object destruction rules.
        tmp_file_holder_;
    end

    methods(Static)
        % returns list of fields, which need to be filled by head function
        form_fields = head_form(sqw_only,keep_data_arrays)
        %
        function obj = apply_op(obj, operation)
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
            obj = obj.pix.apply_op(obj,operation);
        end
        % build sqw from multiple compatible-sqw parts.
        wout = join(w,varargin);
    end
    %======================================================================
    % PageOp methods -- methods, which use PageOp for implementation, so
    % affect all pixels and recalculate image according to changes in pixels
    % (or vise versa)
    methods
        % combine together various sqw objects, containing the same size images
        wout = combine_sqw(w1,varargin);
        wout = split(w,varargin);

        [wout,mask_array] = mask(win, mask_array);

        wout = mask_pixels(win, mask_array,varargin);
        wout = mask_random_fraction_pixels(win,npix);
        wout = mask_random_pixels(win,npix);

        % calculate pixel data range and recalculate image not modifying
        % pixel data
        wout=recompute_bin_data(sqw_obj,out_file_name);
        % apply alignment to pixels
        [obj,al_info] = finalize_alignment(obj,filename);

        % take part of the object limited by full bins (irange) containing
        % fraction of the image grid
        [wout,irange] = section (win,varargin);
        % add various noise to signal
        wout = noisify(w,varargin);

        % Replace the sqw's signal and variance data with requested
        % coordinate values
        w    = coordinates_calc(w, name);
        % Make a higher dimensional dataset from a lower dimensional dataset
        wout = replicate (win,wref);

        %Evaluate a function at the plotting bin centres of sqw object
        wout = func_eval (win, func_handle, pars, varargin)
    end
    %======================================================================
    % Various sqw methods -- difficult to classify
    methods
        wout = cut(obj, varargin); % take cut from the sqw object.
        function wout = cut_sqw(obj,varargin)
            % legacy entrance to cut for sqw object
            wout = cut(obj, varargin{:});
        end
        function wout= rebin(win,varargin)
            wout=rebin_sqw(win,varargin{:});
        end
        wout=rebin_sqw(win,varargin);
        % focusing projections?
        wout = shift_energy_bins (win, dispreln, pars);
        wout = shift_pixels (win, dispreln, pars, opt);
        %
        wout=symmetrise_sqw(win,v1,v2,v3);

        varargout = multifit (varargin);
        %------------------------------------------------------------------
        [ok,mess,varargout] = parse_pixel_indices (win,indx,iw);


        % return the header, common for all runs (average?)
        [header_ave, ebins_all_same]=header_average(header);
        [alatt,angdeg,ok,mess]      = lattice_parameters(win);

        varargout = head(obj,vararin);

        [ok,mess,nd_ref,matching]=dimensions_match(w,nd_ref)
        d=spe(w);


        % Calculate hkl,en of datest pixels
        qw=calculate_qw_pixels(win);
        % Calculate Q^2,en of datest pixels
        qsqr_w = calculate_qsqr_w_pixels (win)
        % Calculate hkl,en of datest pixels using detectors and experiment
        % info
        qw=calculate_qw_pixels2(win)
    end
    %======================================================================
    % METHODS, Available on SQW but redirecting actions to DnD and requesting
    % only DND object for implementation.
    methods
        % Squeezes the data range in the dnd image of an sqw object to
        wout = compact(win)

        function wout = cut_dnd(obj,varargin)
            % legacy entrance to cut for dnd objects
            wout = cut(obj.data,varargin{:});
        end

        function [nd,sz] = dimensions(win)
            % Return size and shape of the image
            % arrays in sqw or dnd object
            [nd,sz] = win(1).data.dimensions();
        end
        % Get limits of the data in an n-dimensional dataset
        [val, n] = data_bin_limits (obj)

        [wout_disp, wout_weight] = dispersion(win, dispreln, pars);
        %------------------------------------------------------------------
        % sigvar interface
        wout              = sigvar(w); % Create sigvar object from sqw object
        [s,var,mask_null] = sigvar_get (w);
        sz                = sigvar_size(w);
        % set sqw object signal and variance from
        w = sigvar_set(win, sigvar_obj);
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
        % build target axes for cut
        [targ_ax_block,targ_proj] = define_target_axes_block(w, targ_proj, pbin, sym)
        function qw=calculate_qw_bins(win,varargin)
            % Calculate qh,qk,ql,en for the centres of the bins of an
            % n-dimensional sqw dataset
            qw = win.data.calculate_qw_bins(varargin{:});
        end
        function [q,en]=calculate_q_bins(win)
            [q,en] = win.data.calculate_q_bins();
        end
        %
        function  save_xye(obj,varargin)
            obj.data.save_xye(varargin{:});
        end
        function  s=xye(w, varargin)
            % Get the bin centres, intensity and error bar for a 1D, 2D, 3D or 4D dataset
            s = w.data.xye(varargin{:});
        end
        %------------------------------------------------------------------
        % May be reasonably extended to sqw->pixels:
        wout = smooth(win, varargin); % Run smooth operation over DnD
        %                             % objects or sqw objects without pixels
        % signal and error for the bin containing a point x on the image
        function [value, sigma] = value(w, x)
            [value, sigma] = w.data.value(x);
        end
        function sz = img_size_bytes(obj)
            % return size of data image expressed in bytes
            sz = obj.data.img_size_bytes();
        end
        function struc = get_se_npix(obj,varargin)
            % return image arrays
            struc = obj.data.get_se_npix(varargin{:});
        end
        function npix = get_npix_block(obj,block_start,block_size)
            % return specified chunk of npix array which describes pixel
            % destribution over block bins.
            npix = obj.data.get_npix_block(block_start,block_size);
        end
        function md = get_dnd_metadata(obj)
            % return metadata describing image
            md = obj.data.get_dnd_metadata();
        end
    end
    %======================================================================
    % Construction and change of state
    methods
        function obj = sqw(varargin)
            obj = obj@SQWDnDBase();

            if nargin==0 % various serializers need empty constructor
                obj.data_ = d0d();
                return;
            end
            obj = obj.init(varargin{:});
        end
        % initialization of empty sqw object or main part of constructor
        obj = init(obj,varargin)
        %
        % WARNING: if an sqw object built from an existing sqw file is set
        %          to be a tmp object, the original file will be automatically
        %          deleted when this object goes out of scope.
        % USE WITH CAUTION!!!
        obj = set_as_tmp_obj(obj,filename)
        %
        obj = deactivate(obj)
        obj = activate(obj,new_file)
        %
    end
    %======================================================================
    % ACCESSORS TO OBJECT PROPERTIES
    methods
        %------------------------------------------------------------------
        % Public getters/setters expose all wrapped data attributes
        function val = get.data(obj)
            val = obj.data_;
        end
        function obj = set.data(obj, d)
            obj = set_data_(obj,d);
        end
        %
        function pix = get.pix(obj)
            pix  = obj.pix_;
        end
        function obj = set.pix(obj,val)
            obj= set_pix_(obj,val);
        end
        %
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
            obj = set_main_header_(obj,val);
        end
        %
        function val = get.experiment_info(obj)
            val = obj.experiment_info_;
        end
        function obj = set.experiment_info(obj,val)
            obj = set_experiment_info_(obj,val);
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
        %------------------------------------------------------------------
        % Read_only accessors and hidden properties
        function nd = get.NUM_DIMS(obj)
            if isempty(obj.data_)
                nd = [];
            else
                nd = obj.data_.NUM_DIMS;
            end
        end
        %
        function fn = get.full_filename(obj)
            % hiddent
            fn = get_full_filename_(obj);
        end
        function obj = set.full_filename(obj,val)
            obj = set_full_filename_(obj,val);
        end
        %
        function is = get.is_tmp_obj(obj)
            is = ~isempty(obj.tmp_file_holder_);
        end
        function is = dnd_type(obj)
            is = obj.pix_.num_pixels == 0;
        end
        %
        function map = get.runid_map(obj)
            map = get_runid_map_(obj);
        end
        %
        function npix = get.npixels(obj)
            npix = obj.pix_.num_pixels;
        end
        function npix = get.num_pixels(obj)
            npix = obj.pix_.num_pixels;
        end
    end
    %======================================================================
    % REDUNDANT and compatibility methods
    methods
        % write sqw object in an sqw file. Superseeded by save(sqw,...) on SQWDnDBase
        write_sqw(obj,sqw_file,vararin);
        % special case of apply_op
        obj = apply(obj, func_handle, args, recompute_bins, compute_variance);
        % old implementation of experiment_info
        function hdr = get.header(obj)
            % return old (legacy) header(s) providing short experiment info
            hdr = get_header_(obj);
        end
    end
    %======================================================================
    % supporting methods for apply_op
    methods
        %----------------------------------
        new_sqw = copy(obj, varargin)
        wh  = get_write_handle(obj, outfile)
        obj = finish_dump(obj,page_op);
        %
    end
    %======================================================================
    % TOBYFIT INTERFACE
    methods
        varargout = resolution_plot (w, varargin);
        %
        [wout, pars_out] = refine_crystal_strip_pars (win, xtal, pars_in);
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
        [cov_proj, cov_spec, cov_hkle] = tobyfit_DGdisk_resfun_covariance(win, ipix);
        [wout,state_out,store_out]=tobyfit_DGfermi_resconv(win,caller,state_in,store_in,...
            sqwfunc,pars,lookup,mc_contributions,mc_points,xtal,modshape);
        [cov_proj, cov_spec, cov_hkle] = tobyfit_DGfermi_resfun_covariance(win, ipix);
    end

    %======================================================================
    methods(Access = protected)
        % Re #962 TODO: probably delete it
        [proj, pbin] = get_proj_and_pbin(w) % Retrieve the projection and
        % binning of an sqw or dnd object

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
        function is = get_is_filebacked(obj)
            is = obj.has_pixels && obj.pix.is_filebacked;
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
        sqw_struct    = make_sqw(ndims);
        detpar_struct = make_sqw_detpar();
        header        = make_sqw_header();

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
            % to allow loadobj to recover new structure from an old structure.
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
