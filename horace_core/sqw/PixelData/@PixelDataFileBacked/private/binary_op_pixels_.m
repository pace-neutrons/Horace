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
sv_ind = obj.get_pixfld_indexes('sig_var');

if pixel_data.is_filebacked
    obj.data_range = PixelDataBase.EMPTY_RANGE;
    %
    % TODO: #975 loop have to be moved level up calculating image in single
    % loop too
    num_pages= obj.num_pages;
    this_sigvar = sigvar();
    other_sigvar =sigvar();
    for i = 1:num_pages
        obj.page_num = i;
        data = obj.data;
        pixel_data.page_num = i;

        this_sigvar.sig_var = obj.sig_var;
        other_sigvar.sig_var = pixel_data.sig_var;

        sig_var = ...
            obj.sigvar_binary_op(this_sigvar, other_sigvar, binary_op, flip);

        data(sv_ind, :) = sig_var;

        obj = obj.format_dump_data(data);

        obj.data_range = ...
            obj.pix_minmax_ranges(data, obj.data_range_);

    end

else
    obj.data_range = PixelDataBase.EMPTY_RANGE;
    %
    % TODO: #975 loop have to be moved level up calculating image in single
    % loop too
    num_pages= obj.num_pages;
    this_sigvar = sigvar();
    other_sigvar = sigvar();
    for i = 1:num_pages
        obj.page_num = i;
        data = obj.data;

        this_sigvar.sig_var = obj.sig_var;
        % this is different from above
        [start_idx, end_idx] = obj.get_page_idx_(i);        
        other_sigvar.sig_var = pixel_data.sig_var(:,start_idx:end_idx);
        %
        
        sig_var = ...
            obj.sigvar_binary_op(this_sigvar, other_sigvar, binary_op, flip);

        data(sv_ind, :) = sig_var;

        obj = obj.format_dump_data(data);

        obj.data_range = ...
            obj.pix_minmax_ranges(data, obj.data_range_);

    end
end
obj = obj.finish_dump();

end  % function
