function obj = sqw_eval_(obj, sqwfunc, ave_pix, all_bins, pars)
    if has_pixels(obj)   % determine if sqw or dnd type
        obj = obj.sqw_eval_pix_(sqwfunc, ave_pix, pars);
    else
        obj = obj.sqw_eval_nopix_(sqwfunc, all_bins, pars);
    end
end
