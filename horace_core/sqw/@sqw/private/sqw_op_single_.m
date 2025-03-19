function obj = sqw_op_single_(obj, sqwfunc, pars, outfile)
%==================================================================================================
% SQW_OP_SINGLE_
% Helper function for sqw_op executed on a full sqw object containing
% pixels
%
% Called by `sqw_op` defined in sqw object
%
% Input:
% ------
%   obj        Dataset that provides the axes and points
%              for the calculation
%
%   sqwfunc    Handle to function that executes operation and modifies pixels
%              (signals and errors as function of other parameters)
%
%   pars       Arguments needed by the function.
%   outfile    The file used for outputting filebacked result
%
% Returns:
% --------
%  obj     sqw object or filebacked sqw object -- result sqw_op operation
%==================================================================================================

eval_op = PageOp_sqw_op();
% file have to be set first to account for the case infile == outfile
if ~isempty(outfile)
    eval_op.outfile = outfile;
end
eval_op = eval_op.init(obj,sqwfunc,pars);

obj = sqw.apply_op(obj,eval_op);
