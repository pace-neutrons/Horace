function pix_out = get_pixels(obj, abs_pix_indices)
% GET_PIXELS Retrieve the pixels at the given indices in the full pixel block,
% return a new PixelData object.
%
%  >> pix_out = pix.get_pixels(15640:19244)  % retrieve pixels at indices 15640 to 19244
%
%  >> pix_out = pix.get_pixels([1, 0, 1])  % retrieve pixels at indices 1 and 3
%
% The function attempts to mimic the behaviour you would see when indexing into
% a Matlab array. The difference being the returned object is a PixelData
% object and not an array.
%
% This function may be useful if you want to extract data for a particular
% image bin.
%
% Input:
% ------
%   abs_pix_indices  A vector of positive integers or a vector of logicals.
%                    If a vector of integers, include the pixels with those
%                    indices, in the given order, in the returned PixelData
%                    object.
%                    If a vector of logicals, keep pixels where the logical
%                    array index is 1 and remove pixels where it's 0.
%
% Output:
% -------
%   pix_out        Another PixelData object containing only the pixels
%                  specified in the abs_pix_indices argument.
%
abs_pix_indices = parse_args(obj, abs_pix_indices);

if obj.is_file_backed_()
    if any(obj.page_dirty_)
        % At least some pixels sit in temporary files

        % Allocate output array
        pix_out = PixelData(numel(abs_pix_indices));

        % Deal with dirty pixels
        [pix_out, dirty_pg_mask] = ...
            assign_dirty_pixels(obj, pix_out, abs_pix_indices);

        % Now assign the clean pixels
        [unique_sorted, ~, idx_map] = unique(abs_pix_indices(~dirty_pg_mask));
        raw_pix = obj.f_accessor_.get_pix_at_indices(unique_sorted);
        pix_out.data(:, ~dirty_pg_mask) = raw_pix(:, idx_map);

    else
        % All pixels in file
        if issorted(abs_pix_indices, 'strictascend')
            pix_out = PixelData(obj.f_accessor_.get_pix_at_indices(abs_pix_indices));
        else
            % get_pix_at_indices requires monotonically increasing indices
            [unique_sorted, ~, idx_map] = unique(abs_pix_indices);
            raw_pix = obj.f_accessor_.get_pix_at_indices(unique_sorted);
            pix_out = PixelData(raw_pix(:, idx_map));
        end
    end
else
    % All pixels in memory
    pix_out = PixelData(obj.data(:, abs_pix_indices));
end

end  % function


% -----------------------------------------------------------------------------
function abs_pix_indices = parse_args(obj, varargin)
    parser = inputParser();
    parser.addRequired('abs_pix_indices', @is_positive_int_vector_or_logical_vector);
    parser.parse(varargin{:});

    abs_pix_indices = parser.Results.abs_pix_indices;
    if islogical(abs_pix_indices)
        if numel(abs_pix_indices) > obj.num_pixels
            if any(abs_pix_indices(obj.num_pixels + 1:end))
                error('PIXELDATA:get_pixels', ...
                      ['The logical indices contain a true value outside of ' ...
                       'the array bounds.']);
            else
                abs_pix_indices = abs_pix_indices(1:obj.num_pixels);
            end
        end
        abs_pix_indices = find(abs_pix_indices);
    end

    max_idx = max(abs_pix_indices);
    if max_idx > obj.num_pixels
        error('PIXELDATA:get_pixels', ...
            'Pixel index out of range. Index must not exceed %i.', ...
            obj.num_pixels);
    end
end


function is = is_positive_int_vector_or_logical_vector(vec)
    is = isvector(vec) && (islogical(vec) || (all(vec > 0 & all(floor(vec) == vec))));
end


function [pix, dirty_pg_mask] = assign_dirty_pixels(obj, pix, abs_pix_indices)
    % Assign dirty pixels to the given pixel data object.
    %
    % Inputs:
    % -------
    %   pix                The PixelData object to assign the dirty data to.
    %   abs_pix_indices    The absolute indices of the required pixels. These
    %                      will be filtered such that only the dirty pixels are
    %                      assigned - the clean pixel indices are discarded.
    %

    % Logical index into abs_pix_indices of all pixels on dirty pages
    % This is used to track the positions of dirty pixels. After the
    % following loop, this is used to remove dirty pixel indices from
    % abs_pix_indices, so we're just left with the "clean" pixels.
    dirty_pg_mask = zeros(size(abs_pix_indices));

    dirty_pages = find(obj.page_dirty_);  % page number of dirty pages
    for i = 1:numel(dirty_pages)
        pg_num = dirty_pages(i);

        % Get the min/max absolute index of the dirty page
        min_idx = (pg_num - 1)*obj.base_page_size + 1;
        max_idx = min_idx + obj.base_page_size;

        % Logical array tracking indices of abs_pix_indices that are in pg_num
        pix_pg_mask = abs_pix_indices >= min_idx & abs_pix_indices < max_idx;

        if ~any(pix_pg_mask)
            continue;
        end

        % Update logical array tracking indexes of dirty pixels
        dirty_pg_mask = dirty_pg_mask | pix_pg_mask;

        % Convert absolute indices into indices relative to the dirty page
        pg_idxs = get_pg_idx_from_absolute_( ...
            obj, abs_pix_indices(pix_pg_mask), pg_num);

        % Load required pixels from temporary files
        pixels = obj.tmp_io_handler_.load_pixels_at_indices( ...
            pg_num, pg_idxs, obj.PIXEL_BLOCK_COLS_);

        pix.data(:, pix_pg_mask) = pixels;
    end
end
