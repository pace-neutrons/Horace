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

inplace_write = ~obj.has_tmp_file;
if inplace_write
    fid = obj.get_append_handle();
    tosave = {'nosave', true};
else
    tosave = {};
end

if pixel_data.is_filebacked

    obj.move_to_first_page();
    pixel_data.move_to_first_page();

    if obj.page_size ~= pixel_data.page_size
        error('PIXELDATA:do_binary_op', ...
              ['Cannot perform binary operation. PixelData objects ' ...
               'must have equal page size.\nFound ''%i'' pixels ' ...
               'in second pixel_data, ''%i'' pixels required.'], ...
              pixel_data.num_pixels, obj.num_pixels);
    end

    while true
        this_sigvar = sigvar(obj.signal, obj.variance);
        other_sigvar = sigvar(pixel_data.signal, pixel_data.variance);
        [obj.signal, obj.variance] = ...
            sigvar_binary_op_(this_sigvar, other_sigvar, binary_op, flip);

        if inplace_write
            fwrite(fid, obj.data, 'single');
        end

        if obj.has_more()
            obj.advance(tosave{:});
            pixel_data.advance();
        else
            break;
        end
    end

else

    obj.move_to_first_page();

    while true
        this_sigvar = sigvar(obj.signal, obj.variance);

        pg_size = obj.base_page_size;
        start_idx = (obj.page_number_ - 1)*pg_size + 1;
        end_idx = min(obj.page_number_*pg_size, obj.num_pixels);

        other_sigvar = sigvar(pixel_data.signal(start_idx:end_idx), ...
                              pixel_data.variance(start_idx:end_idx));
        [obj.signal, obj.variance] = ...
            sigvar_binary_op_(this_sigvar, other_sigvar, binary_op, flip);

        if inplace_write
            fwrite(fid, obj.data, 'single');
        end

        if obj.has_more()
            obj.advance(tosave{:});
        else
            break;
        end

    end
end

if inplace_write
    obj.finalise_append(fid);
end

end  % function
