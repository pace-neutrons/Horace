function obj = binary_op_scalar_(obj, scalar, binary_op, flip)
%% DO_BINARY_OP_SCALAR_ perform the given binary operation between a
% PixelData object and scalar.
%

if isempty(obj.file_handle_)
    obj = obj.get_new_handle();
end

s_ind = obj.check_pixel_fields('signal');
v_ind = obj.check_pixel_fields('variance');

for i = 1:obj.num_pages
    [obj, data] = obj.load_page(i);

    pix_sigvar = sigvar(obj.signal, obj.variance);
    %scalar_sigvar = sigvar(scalar, []);
    scalar_sigvar = scalar;     % TGP 2021-04-11: to work with new classdef sigvar

    [signal, variance] = ...
        sigvar_binary_op_(pix_sigvar, scalar_sigvar, binary_op, flip);

    data(s_ind, :) = signal;
    data(v_ind, :) = variance;

    obj.format_dump_data(data);

end

obj = obj.finalise();
obj = obj.recalc_data_range({'signal', 'variance'});

end
