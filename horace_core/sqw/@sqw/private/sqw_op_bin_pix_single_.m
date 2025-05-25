function obj = sqw_op_bin_pix_single_(obj, sqwfunc, pars,targ_ax_block,targ_proj,opts,i)
%==================================================================================================
% SQW_OP_BIN_PIXELS_SINGLE_
% Helper function for sqw_op_bin_pixels executed on a full sqw object
% containing pixels.
%
% Called by `sqw_op_bin_pixels` defined in sqw object
%
% Input:
% ------
%   obj      --  Dataset that provides the axes and points
%                for the calculation
%
%   sqwfunc   -- Handle to function that executes operation and modifies
%                pixels, namely changs signal and error as function of
%                function parameters and pixels coordinates including the
%                possibilty to change pixels coordinates.
%
%   pars      --  Arguments and parameters used by the function.
%   opts  -   The structure, containing parameters, used to change
%             algorithm behaviour. The used properties of these
%             parameters (fields of the structure) are@
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
    rebin_op = PageOp_sqw_binning(); % standard sqw_bin_pixel algorithm
else
    % allow to use undocumented page_processor inheriting from sqw_op
    % (Advanced debugging, future development)
    rebin_op = opts.pageop_processor;
end
% file have to be set first to account for the case infile == outfile
if ~isempty(opts.outfile{i})
    rebin_op.outfile = opts.outfile{i};
end
if opts.filebacked && ~opts.nopix
    rebin_op.init_filebacked_output = true;
end
rebin_op = rebin_op.init(obj,sqwfunc,pars,targ_ax_block,targ_proj,opts);

obj = sqw.apply_op(obj,rebin_op);
