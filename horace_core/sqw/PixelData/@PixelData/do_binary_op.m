function pix_out = do_binary_op(obj, operand, binary_op, flip)
%% DO_BINARY_OP perform a binary operation between this object and the given
%  operand
%
% Input
% -----
% operand    The second operand to use in the binary operation.
%            The operand must have one of the following types:
%              - scalar double
%              - double array, the size of the array must be equal to
%                obj.num_pixels
%              - object with fields 's' and 'e' (e.g. dnd or sigvar)
%              - another PixelData object with obj.num_pixels equal
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

iter = 1;
pix_out = pix_out.move_to_first_page();
base_page_size = pix_out.page_size;
while true

    pix_sigvar = sigvar(pix_out.signal, pix_out.variance);
    if isscalar(operand) && isa(operand, 'double')
        [pix_out.signal, pix_out.variance] = do_binary_op_double_( ...
                pix_sigvar, operand, binary_op, flip);

    elseif isa(operand, 'double')
        if ~isequal(size(operand), [1, obj.num_pixels])
            required_size = sprintf('[1, %i]', obj.num_pixels);
            actual_size = strjoin(repmat({'%i'}, 1, ndims(operand)), ', ');
            actual_size = sprintf(['[', actual_size, ']'], size(operand));
            error('PIXELDATA:do_binary_op', ...
                  ['Cannot perform binary operation. Double array must ' ...
                   'have size equal to number of pixels.\nFound size ''%s'', ' ...
                   '''%s'' required.'], actual_size, required_size);
        end
        start_idx = (pix_out.page_number_ - 1)*base_page_size + 1;
        end_idx = min(start_idx + base_page_size - 1, obj.num_pixels);
        [pix_out.signal, pix_out.variance] = do_binary_op_double_( ...
                pix_sigvar, operand(start_idx:end_idx), binary_op, flip);

    elseif isa(operand, 'PixelData')
        if iter == 1
            operand.move_to_first_page();
        end
        [pix_out.signal, pix_out.variance] = do_binary_op_pixel_data_(...
                pix_out, operand, binary_op);
        if operand.has_more()
            operand = operand.advance();
        end
    end

    if pix_out.has_more()
        pix_out = pix_out.advance();
        iter = iter + 1;
    else
        break;
    end
end

end

% -----------------------------------------------------------------------------
function [signal, variance] = do_binary_op_double_(pix_sigvar, scalar_value, ...
                                                   binary_op, flip)
    operand_sigvar = sigvar(scalar_value, []);

    if flip
        result = binary_op(operand_sigvar, pix_sigvar);
    else
        result = binary_op(pix_sigvar, operand_sigvar);
    end
    signal = result.s;
    variance = result.e;
end

function [signal, variance] = do_binary_op_pixel_data_(pix, other_pix, ...
                                                       binary_op)
    if pix.num_pixels ~= other_pix.num_pixels
        error('PIXELDATA:do_binary_op_pixel_data_', ...
              ['Cannot perform binary operation. PixelData objects ' ...
               'must have equal number of pixels.\nFound ''%i'' pixels ' ...
               'in second operand, ''%i'' pixels required.'], ...
              other_pix.num_pixels, pix.num_pixels);
    end
    % TODO: deal with case of one PixelData object not being paged whilst the
    % other is
    this_sigvar = sigvar(pix.signal, pix.variance);
    other_sigvar = sigvar(other_pix.signal, other_pix.variance);
    result = binary_op(this_sigvar, other_sigvar);
    signal = result.s;
    variance = result.e;
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
