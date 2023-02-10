function pix_out = do_unary_op(obj, unary_op)
% Perform a unary operation on this object's signal and variance arrays
%
% Input:
% -----
% unary_op   Function handle pointing to the operation to perform. This
%            operation should take a sigvar object as an argument.
%

pix_out = obj;

pg_result = unary_op(sigvar(pix_out.signal, pix_out.variance));
pix_out.signal = pg_result.s;
pix_out.variance = pg_result.e;

end
