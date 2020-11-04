function obj = binary_op_scalar_(obj, scalar, binary_op, flip)
%% DO_BINARY_OP_SCALAR_ perform the given binary operation between a
% PixelData object and scalar.
%

obj = obj.move_to_first_page();

while true
    pix_sigvar = sigvar(obj.signal, obj.variance);
    scalar_sigvar = sigvar(scalar, []);

    [obj.signal, obj.variance] = ...
            sigvar_binary_op_(pix_sigvar, scalar_sigvar, binary_op, flip);

    if obj.has_more()
        obj = obj.advance();
    else
        break;
    end

end
