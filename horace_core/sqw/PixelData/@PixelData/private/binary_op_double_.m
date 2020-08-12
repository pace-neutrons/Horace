function pix_out = binary_op_double_(obj, double_array, binary_op, flip)
%% BINARY_OP_DOUBLE_ perform a binary operation between this PixelData object
% and an array
%
validate_input_array(obj, double_array);

pix_out = copy(obj);

base_page_size = pix_out.max_page_size_;
while true

    pix_sigvar = sigvar(pix_out.signal, pix_out.variance);

    start_idx = (pix_out.page_number_ - 1)*base_page_size + 1;
    end_idx = min(start_idx + base_page_size - 1, obj.num_pixels);

    double_sigvar = sigvar(double_array(start_idx:end_idx), []);
    [pix_out.signal, pix_out.variance] = ...
            sigvar_binary_op_(pix_sigvar, double_sigvar, binary_op, flip);

    if pix_out.has_more()
        pix_out = pix_out.advance();
    else
        break;
    end

end

end  % function


% -----------------------------------------------------------------------------
function validate_input_array(obj, double_array)
    if ~isequal(size(double_array), [1, obj.num_pixels])
        required_size = sprintf('[1, %i]', obj.num_pixels);
        actual_size = strjoin(repmat({'%i'}, 1, ndims(double_array)), ', ');
        actual_size = sprintf(['[', actual_size, ']'], size(double_array));
        error('PIXELDATA:do_binary_op', ...
              ['Cannot perform binary operation. Double array must ' ...
               'have size equal to number of pixels.\nFound size ''%s'', ' ...
               '''%s'' required.'], actual_size, required_size);
    end
end
