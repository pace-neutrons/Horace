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

if pixel_data.is_filebacked
    if obj.base_page_size ~= pixel_data.base_page_size
        error('PIXELDATA:do_binary_op', ...
            ['Cannot perform binary operation. PixelData objects ' ...
            'must have equal page size.\nFound ''%i'' pixels per page' ...
            'in second pixel_data, ''%i'' pixels required.'], ...
            pixel_data.base_page_size, obj.base_page_size);
    end

    for i = 1:obj.n_pages
        obj.load_page(i);
        pixel_data.load_page(i);

        this_sigvar = sigvar(obj.signal, obj.variance);
        other_sigvar = sigvar(pixel_data.signal, pixel_data.variance);
        [obj.signal, obj.variance] = ...
            sigvar_binary_op_(this_sigvar, other_sigvar, binary_op, flip);

        obj.format_dump_data(fid);

    end

else

    for i = 1:obj.n_pages
        obj.page_num = i;
        [start_idx, end_idx] = obj.get_page_idx_(i);

        this_sigvar = sigvar(obj.signal, obj.variance);
        other_sigvar = sigvar(pixel_data.signal(start_idx:end_idx), ...
            pixel_data.variance(start_idx:end_idx));
        [obj.signal, obj.variance] = ...
            sigvar_binary_op_(this_sigvar, other_sigvar, binary_op, flip);
        % Re #892 complete this
        %        obj.format_dump_data(fid);
    end
end
% Re #892 complete this
%obj.finalise(fid);
%
end  % function
