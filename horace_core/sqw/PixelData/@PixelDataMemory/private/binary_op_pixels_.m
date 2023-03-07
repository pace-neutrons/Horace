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


if pixel_data.is_filebacked

    for i = 1:pixel_data.num_pages
        pixel_data.page_num = i;
        [start_idx, end_idx] = pixel_data.get_page_idx_();

        this_sigvar = sigvar(pixel_data.signal(start_idx:end_idx), ...
                             pixel_data.variance(start_idx:end_idx));

        other_sigvar = sigvar(pixel_data.signal, pixel_data.variance);

        [obj.signal(start_idx:end_idx), obj.variance(start_idx:end_idx)] = ...
            sigvar_binary_op_(this_sigvar, other_sigvar, binary_op, flip);

    end

else

    this_sigvar = sigvar(obj.signal, obj.variance);
    other_sigvar = sigvar(pixel_data.signal, pixel_data.variance);

    [obj.signal, obj.variance] = ...
        sigvar_binary_op_(this_sigvar, other_sigvar, binary_op, flip);

end

end  % function
