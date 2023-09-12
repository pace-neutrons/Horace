function obj = binary_op_sigvar_(obj, operand, binary_op, flip, npix)
%% BINARY_OP_SIGVAR_ perform a binary operation between this and a sigvar
%
validate_inputs(obj, operand, npix);

obj = obj.prepare_dump();

sv_ind = obj.get_pixfld_indexes('sig_var');


[npix_chunks, idxs] = split_vector_fixed_sum(npix(:), obj.page_size);

obj.data_range = PixelDataBase.EMPTY_RANGE;
% TODO: #975 loop have to be moved level up calculating image in single
num_pages= obj.num_pages;
for i = 1:num_pages
    obj.page_num = i;
    data = obj.data;

    npix_for_page = npix_chunks{i};
    idx = idxs(:, i);

    pix_sigvar = sigvar(obj.signal, obj.variance);

    if ~isequal(size(npix), [1, 1])
        obj_sigvar = sigvar(...
            replicate_array(operand.s(idx(1):idx(2)), npix_for_page(:))', ...
            replicate_array(operand.e(idx(1):idx(2)), npix_for_page(:))' ...
            );
    end

    sig_var = ...
        sigvar_binary_op_(pix_sigvar, obj_sigvar, binary_op, flip);

    data(sv_ind, :) = sig_var;

    obj = obj.format_dump_data(data);
    obj.data_range = ...
        obj.pix_minmax_ranges(data, obj.data_range);
end
obj = obj.finish_dump();


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
