function obj = binary_op_scalar_(obj, scalar, binary_op, flip)
%% DO_BINARY_OP_SCALAR_ perform the given binary operation between a
% PixelData object and scalar.
%

obj = obj.prepare_dump();

sv_ind = obj.get_pixfld_indexes('sig_var');
obj.data_range = PixelDataBase.EMPTY_RANGE;
%
% TODO: #975 loop have to be moved level up calculating image in single
num_pages= obj.num_pages;
pix_sigvar  = sigvar();	
for i = 1:num_pages
    obj.page_num = i;
    data = obj.data;

    pix_sigvar.sig_var = obj.sig_var;
    %scalar_sigvar = sigvar(scalar, []);
    scalar_sigvar = scalar;     % TGP 2021-04-11: to work with new classdef sigvar

    sig_var = ...
        obj.sigvar_binary_op(pix_sigvar, scalar_sigvar, binary_op, flip);

    data(sv_ind, :) = sig_var;

    obj = obj.format_dump_data(data);

    obj.data_range = ...
        obj.pix_minmax_ranges(data, obj.data_range);

end
obj = obj.finish_dump();

end
