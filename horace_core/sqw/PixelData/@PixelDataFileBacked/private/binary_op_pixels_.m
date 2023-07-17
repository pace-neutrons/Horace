function obj = binary_op_pixels_(obj, pixel_data, binary_op, flip)
%% BINARY_OP_PIXELS_ do a binary operation between PixelData objects 'obj' and
% 'pixel_data'
%

if obj.num_pixels ~= pixel_data.num_pixels
    error('HORACE:PixelDataFileBacked:invalid_argument', ...
        ['Cannot perform binary operation. PixelData objects ' ...
        'must have equal number of pixels.\nFound ''%i'' pixels ' ...
        'in second pixel_data, ''%i'' pixels required.'], ...
        pixel_data.num_pixels, obj.num_pixels);
end

obj = obj.prepare_dump();
s_ind = obj.check_pixel_fields('signal');
v_ind = obj.check_pixel_fields('variance');

if pixel_data.is_filebacked
    obj.data_range = PixelDataBase.EMPTY_RANGE;
    %
    % TODO: #975 loop have to be moved level up calculating image in single
    % loop too
    num_pages= obj.num_pages;
    for i = 1:num_pages
        obj.page_num = i;
        data = obj.data;
        pixel_data.page_num = i;

        this_sigvar = sigvar(obj.signal, obj.variance);
        other_sigvar = sigvar(pixel_data.signal, pixel_data.variance);

        [signal, variance] = ...
            sigvar_binary_op_(this_sigvar, other_sigvar, binary_op, flip);

        data(s_ind, :) = signal;
        data(v_ind, :) = variance;

        obj.format_dump_data(data);

        obj.data_range = ...
            obj.pix_minmax_ranges(data, obj.data_range);

    end

else
    obj.data_range = PixelDataBase.EMPTY_RANGE;
    %
    % TODO: #975 loop have to be moved level up calculating image in single
    % loop too
    num_pages= obj.num_pages;
    for i = 1:num_pages
        obj.page_num = i;
        data = obj.data;

        [start_idx, end_idx] = obj.get_page_idx_(i);

        this_sigvar = sigvar(obj.signal, obj.variance);
        other_sigvar = sigvar(pixel_data.signal(start_idx:end_idx), ...
            pixel_data.variance(start_idx:end_idx));

        [signal, variance] = ...
            sigvar_binary_op_(this_sigvar, other_sigvar, binary_op, flip);

        data(s_ind, :) = signal;
        data(v_ind, :) = variance;

        obj.format_dump_data(data);
        obj.data_range = ...
            obj.pix_minmax_ranges(data, obj.data_range);

    end
end
obj = obj.finalise();

end  % function
