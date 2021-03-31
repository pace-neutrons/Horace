classdef (Abstract) SQWDnDBase
    %SQWDnDBase Abstract SQW/DnD object base class
    %   Abstract class defining common API and atrributes of the SQW and
    %   DnD objects

    properties (Abstract) % Public
    end

    properties (Access = protected)
        % base_property
        data_;
    end

    methods (Abstract, Access = protected)
        wout = unary_op_manager(w, operation_handle);
        wout = binary_op_manager_single(w1,w2,binary_op);
        wout = sqw_eval_pix_(wout, sqwfunc, ave_pix, pars);
    end

    methods  % Public
        [s,var,mask_null] = sigvar_get (w);

        wout = mask(win, mask_array);
        wout = mask_pixels(win, mask_array);
        [sel,ok,mess] = mask_points(win, varargin);
        wout = mask_random_fraction_pixels(win,npix);
        wout = mask_random_pixels(win,npix);

        save(w, varargin);

        [xout,yout,sout,eout,nout] = convert_bins_for_shoelace(win, wref);
        wout = IX_dataset_1d(w);
        wout = IX_dataset_2d(w);
        wout = IX_dataset_3d(w);
        [nd, sz] = dimensions(w);
        [ok,mess,nd_ref] = dimensions_match(w, nd_ref);
        [wout_disp, wout_weight] = dispersion(win, dispreln, pars);
        wout = disp2sqw_eval(win, dispreln, pars, fwhh, opt);
        wout = func_eval(win, func_handle, pars, varargin);
        wout = sqw_eval(win, sqwfunc, pars, varargin);

        varargout = multifit_func (varargin);
        varargout = multifit_sqw (varargin);
        varargout = multifit_sqw_sqw (varargin);

        wout = smooth(win, varargin);
        wout = smooth_units(win, varargin);
    end

    methods (Static)
        [iax, iint, pax, p, noffset, nkeep, mess] = cut_dnd_calc_ubins (pbin, pin, nbin);
    end

    methods (Access = protected)
        wout = binary_op_manager(w1, w2, binary_op);
        [ok, mess] = equal_to_tol_internal(w1, w2, name_a, name_b, varargin);
        wout = recompute_bin_data(w);
        wout = sqw_eval_nopix_(win, sqwfunc, all_bins, pars);
    end

    methods (Abstract)
        pixels = has_pixels(win);
    end

end

