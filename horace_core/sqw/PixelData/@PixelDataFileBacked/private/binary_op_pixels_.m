function obj = binary_op_pixels_(obj, pixel_data, binary_op, flip)
%% BINARY_OP_PIXELS_ do a binary operation between PixelData objects 'obj' and
% 'pixel_data'
%

if obj.num_pixels ~= pixel_data.num_pixels
    error('PIXELDATA:do_binary_op', ...
        ['Cannot perform binary operation. PixelData objects ' ...
        'must have equal number of pixels.\nFound ''%i'' pixels ' ...
        'in second pixel_data, ''%i'' pixels required.'], ...
        pixel_data.num_pixels, obj.num_pixels);
end
% Re #892 complete this
%fid = obj.get_new_handle();

obj = obj.get_new_handle();
s_ind = obj.check_pixel_fields('signal');
v_ind = obj.check_pixel_fields('variance');

if pixel_data.is_filebacked
    if obj.base_page_size ~= pixel_data.base_page_size
        error('PIXELDATA:do_binary_op', ...
            ['Cannot perform binary operation. PixelData objects ' ...
            'must have equal page size.\nFound ''%i'' pixels per page' ...
            'in second pixel_data, ''%i'' pixels required.'], ...
            pixel_data.base_page_size, obj.base_page_size);
    end

    for i = 1:obj.num_pages
        [obj, data] = obj.load_page(i);
        pixel_data.page_num = i;

        this_sigvar = sigvar(obj.signal, obj.variance);
        other_sigvar = sigvar(pixel_data.signal, pixel_data.variance);

        [signal, variance] = ...
            sigvar_binary_op_(this_sigvar, other_sigvar, binary_op, flip);

        data(s_ind, :) = signal;
        data(v_ind, :) = variance;

        obj.format_dump_data(data);

    end

else

    for i = 1:obj.num_pages
        [obj, data] = obj.load_page(i);
        [start_idx, end_idx] = obj.get_page_idx_(i);

        this_sigvar = sigvar(obj.signal, obj.variance);
        other_sigvar = sigvar(pixel_data.signal(start_idx:end_idx), ...
            pixel_data.variance(start_idx:end_idx));

        [signal, variance] = ...
            sigvar_binary_op_(this_sigvar, other_sigvar, binary_op, flip);

        data(s_ind, :) = signal;
        data(v_ind, :) = variance;

        obj.format_dump_data(data);
    end
end

obj = obj.finalise();
obj = obj.recalc_data_range({'signal', 'variance'});

end  % function
