function obj = binary_op_sigvar_(obj, operand, binary_op, flip, npix)
%% BINARY_OP_SIGVAR_ perform a binary operation between this and a sigvar or
% sigvar-like object (e.g. dnd)
%
npix_cum_sum = validate_inputs(obj, operand, npix);

obj.move_to_first_page();
[npix_chunks, idxs] = split_vector_fixed_sum(npix(:), obj.base_page_size, npix_cum_sum);
page_number = 1;
while true
    npix_for_page = npix_chunks{page_number};
    idx = idxs(:, page_number);

    sigvar_pix = sigvar(obj.signal, obj.variance);
    if ~isequal(size(npix), [1, 1])
        sigvar_dnd = sigvar(...
            replicate_array(operand.s(idx(1):idx(2)), npix_for_page(:))', ...
            replicate_array(operand.e(idx(1):idx(2)), npix_for_page(:))' ...
        );
    end

    [obj.signal, obj.variance] = ...
            sigvar_binary_op_(sigvar_pix, sigvar_dnd, binary_op, flip);

    if obj.has_more()
        obj.advance();
    else
        break;
    end
end

end % function

% -----------------------------------------------------------------------------
function npix_cum_sum = validate_inputs(pix, operand, npix)
    dnd_size = sigvar_size(operand);
    if ~isequal(dnd_size, [1, 1]) && ~isequal(dnd_size, size(npix))
        error('PIXELDATA:do_binary_op', ...
            ['dnd operand must have size [1,1] or size equal to the inputted ' ...
            'npix array.\nFound dnd size %s, and npix size %s'], ...
            iarray_to_matstr(dnd_size), iarray_to_matstr(size(npix)));
    end

    npix_cum_sum = cumsum(npix(:));
    if npix_cum_sum(end) ~= pix.num_pixels
        error('PIXELDATA:binary_op_sigvar_', ...
            ['Cannot perform binary operation. Sum of ''npix'' must be ' ...
            'equal to the number of pixels in the PixelData object.\n' ...
            'Found ''%i'' pixels in npix but ''%i'' in PixelData.'], ...
            npix_cum_sum(end), pix.num_pixels);
    end
end
