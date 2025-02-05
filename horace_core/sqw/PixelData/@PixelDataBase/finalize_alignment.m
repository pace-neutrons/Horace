function targ_obj = finalize_alignment(obj, outfile)
% If pixels are misaligned apply pixel alignment to all pixels and store
% result in modified file, if such file is provided.
%
% Optional Input:
% -----
% outfile   File to save the result of operation. If missing or empty, the
% result will be stored in tmp file
%
if nargin<2
    outfile = '';
end
targ_obj = copy(obj);
if ~targ_obj.is_corrected && targ_obj.is_range_valid
    return;
end

pix_op = PageOp_recompute_bins();
pix_op.outfile = outfile;
pix_op.op_name = 'finalize_alignment';

pix_op   = pix_op.init(targ_obj);
targ_obj = targ_obj.apply_op(targ_obj,pix_op);
