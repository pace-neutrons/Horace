classdef (Abstract) SQWDnDBase <  data_op_interface & serializable
    %SQWDnDBase Abstract SQW/DnD object base class
    %
    %   Abstract class defining common API and attributes of the SQW and
    %   DnD objects
    properties(Abstract,Dependent,Hidden=true)
        NUM_DIMS
    end
    %======================================================================
    methods (Abstract)
        %------------------------------------------------------------------
        % various useful operations and methods. Both internal and
        % producing useful result
        pixels = has_pixels(win);     % Check if sqw or dnd object has pixels.
        %                             % DnD object always returns false.
        %
        %------------------------------------------------------------------
        % values for the named argument
        wout = cut(obj, varargin);    % take cut from a sqw or sqw/dnd object
        wout = cut_sqw(obj,varargin); % legacy entrance for cut for sqw objects
        % rebin an object to the other object with the dimensionality
        % smaller then the dimensionality of the current object
        obj = rebin(obj,varargin);
    end
    %======================================================================
    % PageOp methods -- methods, which are implemented through PageOp
    % i.e. affect all pixels and recalculate image according to changes
    %  in pixels or vise versa.
    methods(Abstract)
        wout = func_eval(win, func_handle, pars, varargin);
        %
        [wout,mask_array] = mask(win, mask_array); % mask image data and
        %                             % corresponding pixels if available
        % add random noise with various distribution to signal
        wout = noisify(w,varargin);

        wout = signal(w,name); % Set the intensity of an sqw object to the
        %
        w    = sigvar_set(win, sigvar_obj);
        % take part of the object limited full bins containing fraction of
        % the image grid
        [wout,irange] = section (win,varargin);
        % Make a higher dimensional dataset from a lower dimensional dataset
        wout = replicate (win,wref);
    end
    %----------------------------------------------------------------------
    % PageOp methods implemented on this level
    methods
        wout = sqw_eval(win, sqwfunc, pars, varargin);
    end
    %----------------------------------------------------------------------
    % PageOp abstract protected methods
    methods (Abstract, Access = protected)
        wout = sqw_eval_pix(wout, sqwfunc, ave_pix, pars, outfile, i);
        % REDUNDANT METHOD to remove
        [proj, pbin] = get_proj_and_pbin(w) % Retrieve the projection and
        %                              % binning of an sqw or dnd object
    end
    %======================================================================
    % METHODS, Available on SQW but requesting only DND object for
    % implementation
    methods(Abstract)
        wout = compact(win)
        wout = cut_dnd(obj,varargin); % legacy entrance for cut for dnd objects

        [nd,sz] = dimensions(win)
        [wout_disp, wout_weight] = dispersion(win, dispreln, pars) % Calculate
        %               dispersion relation for dataset or array of datasets.

        % Get limits of the data in an n-dimensional dataset
        [val, n] = data_bin_limits (obj)
        %
        %------------------------------------------------------------------
        % sigvar interface
        wout              = sigvar(w); % Create sigvar object from sqw object
        [s,var,mask_null] = sigvar_get (w);
        sz                = sigvar_size(w);
        %------------------------------------------------------------------
        % titles used when plotting an sqw object
        [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] =...
            data_plot_titles(obj)
        %------------------------------------------------------------------
        % construct dataset from appropriately sized dnd part of an object
        wout = IX_dataset_1d(w);
        wout = IX_dataset_2d(w);
        wout = IX_dataset_3d(w);
        % the maximal range of the image may be produced by target projection applied to the current image.
        range = targ_range(obj,targ_proj,varargin)
        % if the plotting operation should adjust aspect ratio when plotting sqw objects
        status = adjust_aspect(obj)
        % build target axes for cut
        [targ_ax_block,targ_proj] = define_target_axes_block(w, targ_proj, pbin, sym)
        %------------------------------------------------------------------
        % Calculate qh,qk,ql,en for the centres of the bins.
        qw=calculate_qw_bins(win,varargin)
        [q,en]=calculate_q_bins(win)
        %
        save_xye(obj,varargin)
        s=xye(w, varargin)
        %------------------------------------------------------------------
        % May be reasonably extended to sqw->pixels:
        % signal and error for the bin containing a point x on the image
        [value, sigma] = value(w, x)
        wout = smooth(win, varargin); % Run smooth operation over DnD
        %                             % objects or sqw objects without pixels
        sz = img_size_bytes(obj);     % return size of data image used to evaluate necessary memory
        data = get_se_npix(obj,varargin);  % return image arrays
        npix = get_npix_block(obj,block_start,block_size) % return specified chunk of npix array,
        %  which describes pixel destribution over bins
        md = get_dnd_metadata(obj) % return metadata describing image
    end
    properties(Constant,Hidden)
        % the size of the border, used in gen_sqw. The img_db_range in gen_sqw
        % exceeds real pix_range (or input pix_range) by this value.
        border_size = -4*eps
    end

    methods (Static,Hidden) % should be protected but Matlab have some
        % issues with calling this from children
        %
        function [proj, pbin, sym, opt] = process_and_validate_cut_inputs(data,...
                return_cut, varargin)
            % interface to private cut parameters parser/validator
            % checking and parsing cut inputs in any acceptable form.
            %
            % The cut parameters are expressed in the target projection
            % system of coordinates.
            %
            % TODO: do we want an option to express cut ranges in the source
            %       coordinate system?
            ndims = data.dimensions;
            [proj, pbin, sym, opt]= cut_parse_inputs_(data, ndims, return_cut, varargin{:});
        end
        %
    end

    methods  % Public
        [sel,ok,mess] = mask_points(win, varargin);
        cl = save(w, varargin);
        %                             %
        wout = disp2sqw_eval(win, dispreln, pars, fwhh, opt);
        wout = disp2sqw(win, dispreln, pars, fwhh,varargin); % build dispersion relation
        %                             % on image of sqw or dnd object
        % Calculate |Q|^2 for the centres of the bins of an n-dimensional sqw dataset
        [qsqr,en] = calculate_qsqr_bins (win);
        qsqr_w    = calculate_qsqr_w_bins (win,varargin)

        varargout = multifit_func (varargin);
        varargout = multifit_sqw (varargin);
        varargout = multifit_sqw_sqw (varargin);
    end

    methods (Access = protected)
        wout = unary_op_manager(w, operation_handle);
        %
        function [func_handle, pars, opts] = parse_funceval_args(win, func_handle, pars, varargin)
            % Process arguments of func_eval function
            [func_handle, pars, opts] = parse_funceval_args_(win, func_handle, pars, varargin{:});
        end

        [ok, mess] = equal_to_tol_internal(w1, w2, name_a, name_b, varargin);

        wout = sqw_eval_nopix(win, sqwfunc, all_bins, pars); % evaluate function
        % on an image stored in an sqw object

        function [func_handle, pars, opts] = parse_eval_args(win, ...
                func_handle, pars, varargin)
            % parser for funceval function input parameters
            [func_handle, pars, opts] = parse_eval_args_(win, func_handle, ...
                pars, varargin{:});
        end

        function [wout,log_info] = cut_single(obj, tag_proj, targ_axes, outfile,log_level)
            [wout,log_info] = cut_single_(obj, tag_proj, targ_axes, outfile,log_level);
        end
    end

    methods (Access = private)
        dout = smooth_dnd(din, xunit, varargin);
    end
end
