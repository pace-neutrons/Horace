function out_obj = do_unary_op(obj, unary_op)
% Perform a unary operation on this object's signal and variance arrays
% defined by the function, provided as input.
%
% Input:
% -----
% unary_op   Function handle pointing to the operation to perform. This
%            operation should be defined on a sigvar object too.
%
out_obj = obj.copy();

pix_op = PageOp_unary_op();
% if ~isempty(obj.full_filename)
%     pix_op.outfile = obj.full_filename;
% end
pix_op   = pix_op.init(out_obj,unary_op);
out_obj  = out_obj.apply_op(out_obj,pix_op);
