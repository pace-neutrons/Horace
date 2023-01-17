function pix_out = do_unary_op(obj, unary_op)
% Perform a unary operation on this object's signal and variance arrays
%
% Input:
% -----
% unary_op   Function handle pointing to the operation to perform. This
%            operation should take a sigvar object as an argument.
%
if nargout == 1
    % Only do a copy if a return argument exists, otherwise perform the
    % operation on obj
    pix_out = copy(obj);
else
    pix_out = obj;
end

fid = pix_out.get_new_handle();

for i = 1:pix_out.n_pages
    pix_out.load_page(i);
    pg_result = unary_op(sigvar(pix_out.signal, pix_out.variance));
    pix_out.signal = pg_result.s;
    pix_out.variance = pg_result.e;

    pix_out.format_dump_data(fid);
end

pix_out.finalise(fid)