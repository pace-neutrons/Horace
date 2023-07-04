function obj = sqw_eval_pix(obj, sqwfunc, ave_pix, pars, outfile)
%==================================================================================================
% SQW_EVAL_PIX
%
% Helper function for sqw eval executed on a pixel-less object (i.e. DnD or SQW with no pixels
% Called by `sqw_eval_` defined in sqw/DnDBase
%
% Input:
% ------
%   obj        Dataset (or array of datasets) that provides the axes and points
%              for the calculation
%
%   sqwfunc    Handle to function that calculates S(Q,w)
%   ave_pix    Boolean flag wither to apply function to averaged bin data
%   pars       Arguments needed by the function.
%   outfile    The file used for filebacking and output
%
%==================================================================================================

if obj.pix.is_filebacked
    if ave_pix
        obj = do_sqw_eval_average_filebacked_(obj, sqwfunc, pars, outfile);
    else
        obj = do_sqw_eval_filebacked_(obj, sqwfunc, pars, outfile);
    end
else
    obj = do_sqw_eval_memory_(obj, sqwfunc, pars, ave_pix);
end

end % of function sqw_eval_pix_
