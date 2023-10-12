function obj = do_unary_op(obj, unary_op)
% Perform a unary operation on this object's signal and variance arrays
%
% Input:
% -----
% unary_op   Function handle pointing to the operation to perform. This
%            operation should be defined on a sigvar object too.
%

pix_op = PageOp_unary_op();
[pix_op,obj] = pix_op.init(obj,unary_op);
obj    = obj.apply_c(obj,pix_op);
