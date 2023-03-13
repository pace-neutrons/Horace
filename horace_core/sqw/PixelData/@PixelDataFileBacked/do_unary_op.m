function pix_out = do_unary_op(obj, unary_op)
% Perform a unary operation on this object's signal and variance arrays
%
% Input:
% -----
% unary_op   Function handle pointing to the operation to perform. This
%            operation should take a sigvar object as an argument.
%

pix_out = obj;

pix_out = pix_out.get_new_handle();
s_ind = obj.check_pixel_fields('signal');
v_ind = obj.check_pixel_fields('variance');

for i = 1:obj.num_pages
    [obj, data] = obj.load_page(i);

    pix_sigvar = sigvar(obj.signal, obj.variance);
    pg_result = unary_op(pix_sigvar);

    data(s_ind, :) = pg_result.s;
    data(v_ind, :) = pg_result.e;

    pix_out.format_dump_data(data);
end

pix_out = pix_out.finalise();
pix_out = pix_out.recalc_data_range({'signal', 'variance'});

end
