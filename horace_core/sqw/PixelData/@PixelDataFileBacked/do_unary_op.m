function pix_out = do_unary_op(obj, unary_op)
% Perform a unary operation on this object's signal and variance arrays
%
% Input:
% -----
% unary_op   Function handle pointing to the operation to perform. This
%            operation should take a sigvar object as an argument.
%

pix_out = obj;

pix_out = pix_out.prepare_dump();
s_ind = obj.check_pixel_fields('signal');
v_ind = obj.check_pixel_fields('variance');

n_pages = obj.num_pages;
obj.data_range = PixelDataBase.EMPTY_RANGE;

for i = 1:n_pages
    obj.page_num = i;
    data = obj.data;

    pix_sigvar = sigvar(data(s_ind,:), data(v_ind,:));
    pg_result  = unary_op(pix_sigvar);

    data(s_ind, :) = pg_result.s;
    data(v_ind, :) = pg_result.e;
    obj.data_range = ...
            obj.pix_minmax_ranges(data, obj.data_range);

    pix_out.format_dump_data(data);
end

pix_out = pix_out.finalise();


end
