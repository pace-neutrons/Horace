function obj = sqw_op_single_(obj, sqwfunc, pars, opts,i)
%==================================================================================================
% SQW_OP_SINGLE_
% Helper function for sqw_op executed on a full sqw object containing
% pixels
%
% Called by `sqw_op` defined in sqw object
%
% Input:
% ------
%   obj       --  Dataset that provides the axes and points
%                for the calculation
%
%   sqwfunc   -- Handle to function that executes operation and modifies
%                pixels, namely changs signal and error as function of
%                function parameters and pixels coordinates.
%
%   pars      --  Arguments and parameters used by the function.
%   opts        The structure, containing parameters, used to change
%               algorithm behaviour. The used properties of these
%               parameters (fields of the structure) are@
%   .outfile  -- The file used for outputting filebacked result
%   .thePageOpProcessor 
%            -- if not empty, a child of PageOp_sqw_op class, which
%               provides additional features to PageOp_sqw_op operations
%               if empty, basic PageOp_sqw_op class will be used.
%
% Returns:
% --------
%  obj       -- sqw object or filebacked sqw object -- result of sqw_op
%               operation
%==================================================================================================

if isempty(opts.pageop_processor)
    eval_op = PageOp_sqw_op();
else
    eval_op = opts.pageop_processor;    
end
% file have to be set first to account for the case infile == outfile
if ~isempty(opts.outfile)
    eval_op.outfile = opts.outfile{i};
end
if opts.filebacked
    eval_op.init_filebacked_output = true;
end
eval_op = eval_op.init(obj,sqwfunc,pars,opts);

obj = sqw.apply_op(obj,eval_op);
