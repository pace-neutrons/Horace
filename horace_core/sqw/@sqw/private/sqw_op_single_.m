function obj = sqw_op_single_(obj, sqwfunc, ave_pix, pars, outfile)
%==================================================================================================
% SQW_OP_SINGLE_
% Helper function for sqw_op executed on a full sqw object containing
% pixels
%
% Called by `sqw_op` defined in sqw object
%
% Input:
% ------
%   obj        Dataset (or array of datasets) that provides the axes and points
%              for the calculation
%
%   sqwfunc    Handle to function that executes operation and modifies pixels
%
%   ave_pix    Boolean flag wither to apply function to averaged bin data
%   pars       Arguments needed by the function.
%   outfile    The file used for outputting filebacked result
%
%==================================================================================================

eval_op = PageOp_sqw_op();
% file have to be set first to account for the case infile == outfile
if ~isempty(outfile)
    eval_op.outfile = outfile;
end
eval_op = eval_op.init(obj,sqwfunc,pars,ave_pix);

obj = sqw.apply_op(obj,eval_op);
