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

%[obj, data] = obj.apply(sqwfunc, args, data, true); <- does not work
eval_op = PageOp_sqw_eval();
if ~isempty(outfile)
    eval_op.outfile = outfile;
end
[eval_op,obj] = eval_op.init(obj,sqwfunc,pars,ave_pix);
obj = obj.apply_c(eval_op);
