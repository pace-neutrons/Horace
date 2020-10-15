function pix_out = get_pixels(obj, pix_indices)
% GET_PIXELS Retrieve the pixels at the given indices in the current page, return
% a new PixelData object
%
%  >> pix_out = pix.get_pixels(1:100)  % retrieve pixels at index 1-100
%
%  >> pix_out = pix.get_pixels([1, 0, 1])
%
% The function attempts to mimic the behaviour you would see when indexing into
% an Matlab array. The difference being the returned object is a PixelData
% object and not an array.
%
% This function may be useful if you want to extract data for a particular
% image bin.
%
% Input:
% ------
%   pix_indices    A vector of positive inegers or a vector of logicals.
%                  If a vector of integers, include the pixels with those
%                  indices, in the given order, in the returned PixelData
%                  object.
%                  If a vector of logicals keep pixels where the logical array
%                  index is 1 and remove pixels where it's 0.
%
% Output:
% -------
%   pix_out        Another PixelData object containing only the pixels
%                  specified in the pix_indices argument.
%
[pix_indices, max_idx] = parse_args(obj, pix_indices);

if obj.is_file_backed_()
    first_required_page = ceil(min(pix_indices)/obj.max_page_size_);
    obj.move_to_page(first_required_page);

    pix_out = PixelData(numel(pix_indices));

    [pg_idxs, global_idxs] = get_idxs_in_current_pg(obj, pix_indices);
    pix_out.data(:, global_idxs) = obj.data(:, pg_idxs);
    while obj.has_more()
        obj.advance();
        if (obj.page_number_ - 1)*obj.max_page_size_ + 1 > max_idx
            break;
        end
        [pg_idxs, global_idxs] = get_idxs_in_current_pg(obj, pix_indices);
        pix_out.data(:, global_idxs) = obj.data(:, pg_idxs);
    end
else
    pix_out = PixelData(obj.data(:, pix_indices));
end

end  % function


% -----------------------------------------------------------------------------
function [pix_indices, max_idx] = parse_args(obj, varargin)
    parser = inputParser();
    parser.addRequired('pix_indices', @is_positive_int_vector_or_logical_vector);
    parser.parse(varargin{:});

    pix_indices = parser.Results.pix_indices;
    if islogical(pix_indices)
        pix_indices = find(pix_indices);
    end

    max_idx = max(pix_indices);
    if max_idx > obj.num_pixels
        error('PIXELDATA:get_pixels', ...
            'Pixel index out of range. Index must not exceed %i.', ...
            obj.num_pixels);
    end
end


function is = is_positive_int_vector_or_logical_vector(vec)
    is = isvector(vec) && (islogical(vec) || (all(vec > 0 & all(floor(vec) == vec))));
end


function [idx_in_pg, global_idx] = get_idxs_in_current_pg(obj, abs_indices)
    % Extract the indices from abs_indices that lie within the bounds of the
    % currently cached page of data.
    % Get the corresponding absolute indices as well.
    %
    pg_start_idx = (obj.page_number_ - 1)*obj.max_page_size_ + 1;
    pg_end_idx = pg_start_idx + obj.max_page_size_ - 1;

    global_idx = find((abs_indices >= pg_start_idx) & (abs_indices <= pg_end_idx));
    idx_in_pg = abs_indices(global_idx) - (obj.page_number_ - 1)*obj.max_page_size_;
end
