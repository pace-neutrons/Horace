function pix_out = binary_op_pixels_(obj, pixel_data, binary_op, flip)
%% BINARY_OP_PIXELS_ do a binary operation between PixelData objects 'obj' and
% 'pixel_data'
%
pix_out = copy(obj);

pixel_data.move_to_first_page();
while true

    if obj.num_pixels ~= pixel_data.num_pixels
        error('PIXELDATA:do_binary_op', ...
              ['Cannot perform binary operation. PixelData objects ' ...
               'must have equal number of pixels.\nFound ''%i'' pixels ' ...
               'in second pixel_data, ''%i'' pixels required.'], ...
              pixel_data.num_pixels, obj.num_pixels);
    end

    this_sigvar = sigvar(pix_out.signal, pix_out.variance);
    if pixel_data.is_file_backed_()

        other_sigvar = sigvar(pixel_data.signal, pixel_data.variance);
        [pix_out.signal, pix_out.variance] = ...
                sigvar_binary_op_(this_sigvar, other_sigvar, binary_op, flip);

        if pixel_data.has_more()
            pixel_data = pixel_data.advance();
        end

    else

        pg_size = pix_out.max_page_size_;
        start_idx = (pix_out.page_number_ - 1)*pg_size + 1;
        end_idx = min(pix_out.page_number_*pg_size, obj.num_pixels);

        other_sigvar = sigvar(pixel_data.signal(start_idx:end_idx), ...
                              pixel_data.variance(start_idx:end_idx));
        [pix_out.signal, pix_out.variance] = ...
                sigvar_binary_op_(this_sigvar, other_sigvar, binary_op, flip);

    end

    if pix_out.has_more()
        pix_out = pix_out.advance();
    else
        break;
    end

end

end  % function
