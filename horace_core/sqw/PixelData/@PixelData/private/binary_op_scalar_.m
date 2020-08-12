function pix_out = binary_op_scalar_(obj, scalar, binary_op, flip)
%% DO_BINARY_OP_SCALAR_ perform the given binary operation between a
% PixelData object and scalar.
%
pix_out = copy(obj);

pix_out = pix_out.move_to_first_page();

while true
    pix_sigvar = sigvar(pix_out.signal, pix_out.variance);
    scalar_sigvar = sigvar(scalar, []);

    [pix_out.signal, pix_out.variance] = ...
            sigvar_binary_op_(pix_sigvar, scalar_sigvar, binary_op, flip);

    if pix_out.has_more()
        pix_out = pix_out.advance();
    else
        break;
    end

end
