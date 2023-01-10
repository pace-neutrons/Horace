function obj = binary_op_scalar_(obj, scalar, binary_op, flip)
%% DO_BINARY_OP_SCALAR_ perform the given binary operation between a
% PixelData object and scalar.
%

obj.move_to_first_page();

while true
    pix_sigvar = sigvar(obj.signal, obj.variance);
    %scalar_sigvar = sigvar(scalar, []);
    scalar_sigvar = scalar;     % TGP 2021-04-11: to work with new classdef sigvar

    [obj.signal, obj.variance] = ...
            sigvar_binary_op_(pix_sigvar, scalar_sigvar, binary_op, flip);

    if obj.has_more()
        obj.advance();
    else
        break;
    end

end
