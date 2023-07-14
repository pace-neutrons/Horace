function obj = binary_op_scalar_(obj, scalar, binary_op, flip)
%% DO_BINARY_OP_SCALAR_ perform the given binary operation between a
% PixelData object and scalar.
%

if isempty(obj.file_handle_)
    obj = obj.get_new_handle();
end

s_ind = obj.check_pixel_fields('signal');
v_ind = obj.check_pixel_fields('variance');
obj.data_range = PixelDataBase.EMPTY_RANGE;
%
% TODO: #975 loop have to be moved level up calculating image in single
num_pages= obj.num_pages;
for i = 1:num_pages
    obj.page_num = i;
    data = obj.data;

    pix_sigvar = sigvar(obj.signal, obj.variance);
    %scalar_sigvar = sigvar(scalar, []);
    scalar_sigvar = scalar;     % TGP 2021-04-11: to work with new classdef sigvar

    [signal, variance] = ...
        sigvar_binary_op_(pix_sigvar, scalar_sigvar, binary_op, flip);

    data(s_ind, :) = signal;
    data(v_ind, :) = variance;

    obj.format_dump_data(data);

    obj.data_range = ...
        obj.pix_minmax_ranges(data, obj.data_range);

end
obj = obj.finalise();


