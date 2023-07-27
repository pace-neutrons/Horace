function [pix_out, data] = do_unary_op(obj, unary_op, data)
% Perform a unary operation on this object's signal and variance arrays
%
% Input:
% -----
% unary_op   Function handle pointing to the operation to perform. This
%            operation should take a sigvar object as an argument.
%
% data       dnd object containing npix information

pix_out = obj;

pg_result = unary_op(sigvar(pix_out.signal, pix_out.variance));
pix_out.signal = pg_result.s;
pix_out.variance = pg_result.e;
pix_out = pix_out.reset_changed_coord_range({'signal', 'variance'});

if exist('data', 'var')
    [data.s, data.e] = pix_out.compute_bin_data(data.npix);
end

end
