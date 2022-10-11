function obj = binary_op_pixels_(obj, pixel_data, binary_op, flip)
%% BINARY_OP_PIXELS_ do a binary operation between PixelData objects 'obj' and
% 'pixel_data'
%
obj.move_to_first_page();
pixel_data.move_to_first_page();
while true

    if obj.num_pixels ~= pixel_data.num_pixels
        error('PIXELDATA:do_binary_op', ...
              ['Cannot perform binary operation. PixelData objects ' ...
               'must have equal number of pixels.\nFound ''%i'' pixels ' ...
               'in second pixel_data, ''%i'' pixels required.'], ...
              pixel_data.num_pixels, obj.num_pixels);
    end

    this_sigvar = sigvar(obj.signal, obj.variance);
    if pixel_data.is_filebacked()

        other_sigvar = sigvar(pixel_data.signal, pixel_data.variance);
        [obj.signal, obj.variance] = ...
                sigvar_binary_op_(this_sigvar, other_sigvar, binary_op, flip);

        if pixel_data.has_more()
            pixel_data.advance();
        end

    else

        pg_size = obj.base_page_size;
        start_idx = (obj.page_number_ - 1)*pg_size + 1;
        end_idx = min(obj.page_number_*pg_size, obj.num_pixels);

        other_sigvar = sigvar(pixel_data.signal(start_idx:end_idx), ...
                              pixel_data.variance(start_idx:end_idx));
        [obj.signal, obj.variance] = ...
                sigvar_binary_op_(this_sigvar, other_sigvar, binary_op, flip);

    end

    if obj.has_more()
        obj.advance();
    else
        break;
    end

end

end  % function
