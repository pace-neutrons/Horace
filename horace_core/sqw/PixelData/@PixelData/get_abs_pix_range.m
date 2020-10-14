function pix_out = get_abs_pix_range(obj, start_idx, end_idx)
%% GET_ABS_PIX_RANGE get the given range of pixels by absolute index into sqw
% file backing the given PixelData object
%
% This function may be useful if you want to extract data for a particular
% image bin.
%
[start_idx, end_idx] = parse_args(obj, start_idx, end_idx);

start_page_num = ceil(start_idx/obj.max_page_size_);
obj.move_to_page(start_page_num);

num_pix_in_range = end_idx - start_idx;
pg_start_idx = start_idx - (obj.page_number_ - 1)*obj.max_page_size_;
pg_end_idx = min(obj.max_page_size_, pg_start_idx + num_pix_in_range);

leftover = (pg_start_idx + num_pix_in_range) - obj.max_page_size_;
pix_out = obj.get_pixels(pg_start_idx:pg_end_idx);
while leftover > 0
    obj = obj.advance();

    pg_end_idx = min(obj.max_page_size_, leftover);
    leftover = leftover - obj.max_page_size_;
    pix_out.append(obj.get_pixels(1:pg_end_idx));
end

end  % function


% -----------------------------------------------------------------------------
function [start_idx, end_idx] = parse_args(obj, varargin)
    parser = inputParser();
    parser.addRequired('start_idx', @is_scalar_int_greater_than_zero);
    parser.addRequired('end_idx', @is_scalar_int_greater_than_zero);
    parser.parse(varargin{:});

    start_idx = parser.Results.start_idx;
    end_idx = parser.Results.end_idx;

    if start_idx > end_idx
        error('PIXELDATA:get_abs_pix_range', ...
              ['Argument ''end_idx'' cannot be larger than ''start_idx''\n' ...
               'Found start_idx = %i and end_idx = %i.'], start_idx, end_idx);
    end

    if end_idx > obj.num_pixels
        error('PIXELDATA:get_abs_pix_range', ...
              ['Given end_idx exceeds the number of pixels.\nFound ' ...
               'end_idx = %i, %i pixels in object.'], end_idx, obj.num_pixels);
    end
end


function is = is_scalar_int_greater_than_zero(int_candidate)
    is = isscalar(int_candidate) ...
        && (floor(int_candidate) == int_candidate) ...
        && int_candidate > 0;
end
