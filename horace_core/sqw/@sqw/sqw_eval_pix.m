function obj = sqw_eval_pix(obj, sqwfunc, pars,options)
%==================================================================================================
% SQW_EVAL_PIX
%
% Helper function for sqw_eval executed on a full sqw object containing
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
%   pars       Arguments needed by the function.
%   options  -- structure with fields containing fine-tunning parameters of the
%               evaluation algorithm namely:
%   .ave_pix    Boolean flag wither to apply function to averaged bin data
%   .outfile    The file used for outputting filebacked result
%
% Optional:
%
% init_filebacked_output
%    -- if true, make object filebacked even if it fits memory. Default --
%       false
%
%==================================================================================================

eval_op = PageOp_sqw_eval();
% file have to be set first to account for the case infile == outfile
if ~isempty(options.outfile)
    eval_op.outfile = options.outfile;
end

eval_op.init_filebacked_output = (options.filebacked|| obj.is_filebacked);

eval_op = eval_op.init(obj,sqwfunc,pars,options.average);
eval_op.do_nopix = options.nopix;

obj = sqw.apply_op(obj,eval_op);
