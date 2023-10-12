function obj = sqw_eval_pix(obj, sqwfunc, ave_pix, pars, outfile)
%==================================================================================================
% SQW_EVAL_PIX
%
% Helper function for sqw eval executed on a full sqw object containing
% pixels
%
% Called by `sqw_eval` defined in sqw/DnDBase
%
% Input:
% ------
%   obj        Dataset (or array of datasets) that provides the axes and points
%              for the calculation
%
%   sqwfunc    Handle to function that calculates S(Q,w)
%   ave_pix    Boolean flag wither to apply function to averaged bin data
%   pars       Arguments needed by the function.
%   outfile    The file used for outputing filebacked result
%
%==================================================================================================

eval_op = PageOp_sqw_eval();
% file have to be set first to account for the case infile == outfile
if ~isempty(outfile)
    eval_op.outfile = outfile;
end
[eval_op,obj] = eval_op.init(obj,sqwfunc,pars,ave_pix);

obj = obj.apply_c(eval_op);
