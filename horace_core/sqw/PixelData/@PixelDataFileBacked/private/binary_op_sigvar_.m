function obj = binary_op_sigvar_(obj, operand, binary_op, flip, npix)
%% BINARY_OP_SIGVAR_ perform a binary operation between this and a sigvar
%

validate_inputs(obj, operand, npix);

if isempty(obj.file_handle_)
    obj = obj.get_new_handle();
end

s_ind = obj.check_pixel_fields('signal');
v_ind = obj.check_pixel_fields('variance');

[npix_chunks, idxs] = split_vector_fixed_sum(npix(:), obj.page_size);

for i = 1:obj.num_pages
    [obj, data] = obj.load_page(i);
    npix_for_page = npix_chunks{i};
    idx = idxs(:, i);

    pix_sigvar = sigvar(obj.signal, obj.variance);

    if ~isequal(size(npix), [1, 1])
        obj_sigvar = sigvar(...
            replicate_array(operand.s(idx(1):idx(2)), npix_for_page(:))', ...
            replicate_array(operand.e(idx(1):idx(2)), npix_for_page(:))' ...
        );
    end

    [signal, variance] = ...
        sigvar_binary_op_(pix_sigvar, obj_sigvar, binary_op, flip);

    data(s_ind, :) = signal;
    data(v_ind, :) = variance;

    obj.format_dump_data(data);
end

obj = obj.finalise();
obj = obj.recalc_data_range({'signal', 'variance'});

end % function

function validate_inputs(pix, operand, npix)
    dnd_size = sigvar_size(operand);
    if ~isequal(dnd_size, [1, 1]) && ~isequal(dnd_size, size(npix))
        error( ...
            'HORACE:PixelDataFileBacked:invalid_argument', ...
            ['sigvar operand''s signal array must have size [1  1] or size ' ...
             'equal to the inputted npix array.\n' ...
             'Found operand signal array size [%s], and npix size [%s]'], ...
            num2str(dnd_size), num2str(size(npix)));
    end

    num_pix = sum(npix(:));
    if num_pix ~= pix.num_pixels
        error('HORACE:PixelDataFileBacked:invalid_argument', ...
              ['Cannot perform binary operation. Sum of ''npix'' must be ' ...
               'equal to the number of pixels in the PixelData object.\n' ...
               'Found ''%i'' pixels in npix but ''%i'' in PixelData.'], ...
              num_pix, pix.num_pixels);
    end
end
