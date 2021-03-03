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
        wout = sqw_eval_(wout, sqwfunc, ave_pix, all_bins, pars);
    end

    methods  % Public
        wout = IX_dataset_1d (w);
        wout = IX_dataset_2d (w);
        wout = IX_dataset_3d (w);
        [nd, sz] = dimensions(w);
        wout = disp2sqw_eval(win, dispreln, pars, fwhh, opt);
        wout = func_eval(win, func_handle, pars, varargin);
        wout = sqw_eval(win, sqwfunc, pars, varargin);
    end

    methods (Access = protected)
        wout = binary_op_manager(w1, w2, binary_op);
        [ok, mess] = equal_to_tol_internal(w1, w2, name_a, name_b, varargin);

        wout = sqw_eval_nopix_(win, sqwfunc, all_bins, pars);
    end

    methods (Abstract)
        pixels = has_pixels(win);
    end

end

