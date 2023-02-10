function obj = binary_op_scalar_(obj, scalar, binary_op, flip)
%% DO_BINARY_OP_SCALAR_ perform the given binary operation between a
% PixelData object and scalar.
%
% Re  #928 fix this
%fid = obj.get_new_handle();

for i = 1:obj.n_pages
    obj.page_num = i;

    pix_sigvar = sigvar(obj.signal, obj.variance);
    %scalar_sigvar = sigvar(scalar, []);
    scalar_sigvar = scalar;     % TGP 2021-04-11: to work with new classdef sigvar

    [obj.signal, obj.variance] = ...
        sigvar_binary_op_(pix_sigvar, scalar_sigvar, binary_op, flip);
% Re  #928 fix this
%    obj.format_dump_data(fid);

end
% Re  #928 fix this
%obj.finalise(fid);

end
