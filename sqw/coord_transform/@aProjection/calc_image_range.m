function   range = calc_image_range(obj,minmax_val)
% Process image range from pixels range and defined transformation
    if ~exist('minmax_val','var')
        minmax_val = obj.urange;
    end

    range  = calculate_img_range_(obj,minmax_val);
end

