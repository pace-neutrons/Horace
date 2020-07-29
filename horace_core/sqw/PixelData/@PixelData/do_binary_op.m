function pix_out = do_binary_op(obj, operand, binary_op, flip)
%% DO_BINARY_OP perform a binary operation between this object and the given
%  operand
%
% Input
% -----
% operand    The second operand to use in the binary operation.
%
% binary_op  Function handle pointing to the desired binary operation. The
%            function should take 2 objects with '.s' and '.e' attributes, e.g.
%            a sigvar object
% flip       Flip the order of the operands, e.g. perform "this - operand" if
%            flip is false, perform "operand - this" if flip is true.
%
if ~exist('flip', 'var')
    flip = false;
end
pix_out = copy(obj);

if isscalar(operand)
    do_op_func = @do_binary_op_scalar_;
elseif isa(operand, 'sqw') && is_sqw_type(operand)
    do_op_func = @do_binary_op_sqw_;
elseif is_property(operand, 's') && is_property(operand, 'e')
    do_op_func = @do_binary_op_dnd_;
elseif isa(operand, 'double')
    do_op_func = @do_binary_op_array_;
else
    error('PIXELDATA:do_binary_op', ...
          ['Cannot perform binary operation between PixelData and ''%s'' ' ...
           'object.'], class(operand));
end

pix_out = pix_out.move_to_first_page();
while true

    pix_sigvar = sigvar(pix_out.signal, pix_out.variance);
    [pix_out.signal, pix_out.variance] = do_op_func(pix_sigvar, operand, ...
                                                    binary_op, flip);

    if pix_out.has_more()
        pix_out = pix_out.advance();
    else
        break;
    end
end

end

% -----------------------------------------------------------------------------
function [signal, variance] = do_binary_op_scalar_(pix_sigvar, scalar_value, ...
                                                   binary_op, flip)
    operand_sigvar = sigvar(scalar_value, []);

    if exist('flip', 'var') && flip
        result = binary_op(operand_sigvar, pix_sigvar);
    else
        result = binary_op(pix_sigvar, operand_sigvar);
    end
    signal = result.s;
    variance = result.e;
end

function [signal, variance] = do_binary_op_array_(pix_sigvar, double_array, ...
                                                  binary_op, flip)
end

function [signal, variance] = do_binary_op_sqw_(pix_sigvar, other_sqw, ...
                                                binary_op, flip)

end

function [signal, variance] = do_binary_op_dnd_(pix_sigvar, dnd_obj, ...
                                                binary_op, flip)

end

function is = is_property(object, property)
    is = true;
    try
        object.(property);
    catch ME
        if strcmp(ME.identifier, 'MATLAB:nonExistentField')
            is = false;
        end
    end
end
