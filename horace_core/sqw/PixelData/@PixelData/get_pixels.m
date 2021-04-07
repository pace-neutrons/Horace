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
%                    The syntax for these indices attempts to replicate indexing
%                    into a regular Matlab array. You can use logical indices
%                    as well as normal indices, and you can index into the array
%                    "out-of-order". However, you cannot use `end`, but it is
%                    possible to achieve the same effect using the `num_pixels`
%                    property.
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

        % Logical index into abs_pix_indices of all pixels on dirty pages
        % This is used to track the positions of assigned pixels. We can use
        % this to remove pixel indices from abs_pix_indices, so we're just left
        % with the unassigned pixels.
        pix_assigned = zeros(size(abs_pix_indices));

        % Deal with currently cached page
        if ~obj.cache_is_empty_()
            [pg_idxs, global_idx] = get_pg_idx_from_absolute_( ...
                obj, abs_pix_indices, obj.page_number_);
            pix_out.data(:, global_idx) = obj.data(:, pg_idxs);

            pix_assigned = get_pix_pg_mask(obj, abs_pix_indices, obj.page_number_);
        end

        % Deal with dirty pixels
        [pix_out, pix_assigned] = read_and_assign_dirty_pixels( ...
            obj, pix_out, abs_pix_indices, pix_assigned);

        % If there are pixels left to assign, load them from .sqw file
        if ~all(pix_assigned)
            pix_out.data(:, ~pix_assigned) = ...
                read_clean_pix(obj, abs_pix_indices(~pix_assigned));
        end

    else
        pix_out = PixelData(read_clean_pix(obj, abs_pix_indices));
    end
else
    % All pixels in memory
    pix_out = PixelData(obj.data(:, abs_pix_indices));
end



% -----------------------------------------------------------------------------
function abs_pix_indices = parse_args(obj, varargin)
parser = inputParser();
parser.addRequired('abs_pix_indices', @isindex);
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


function [pix, pix_assigned] = read_and_assign_dirty_pixels( ...
    obj, pix, abs_pix_indices, pix_assigned)
% Assign dirty pixels to the given pixel data object.
%
% Inputs:
% -------
%   pix                The PixelData object to assign the dirty data to.
%   abs_pix_indices    The absolute indices of the required pixels. These
%                      will be filtered such that only the dirty pixels are
%                      assigned - the clean pixel indices are discarded.
%  pix_assigned        Logical array with true where the pixel at that
%                      index has already been assigned to 'pix'.
%
dirty_pages = find(obj.page_dirty_);  % page number of dirty pages
for i = 1:numel(dirty_pages)
    pg_num = dirty_pages(i);

    if (pg_num == obj.page_number_) && ~obj.cache_is_empty_()
        % pix in cached page so we ignore temp files and use the cache
        continue
    end

    % Logical array tracking indices of abs_pix_indices that are in pg_num
    pix_pg_mask = get_pix_pg_mask(obj, abs_pix_indices, pg_num);
    if ~any(pix_pg_mask)
        continue
    end

    % Update logical array tracking indexes of dirty pixels
    pix_assigned = pix_assigned | pix_pg_mask;

    % Convert absolute indices into indices relative to the dirty page
    pg_idxs = get_pg_idx_from_absolute_( ...
        obj, abs_pix_indices(pix_pg_mask), pg_num);

    % Load required pixels from temporary files
    pixels = obj.tmp_io_handler_.load_pixels_at_indices( ...
        pg_num, pg_idxs, obj.PIXEL_BLOCK_COLS_);

    pix.data(:, pix_pg_mask) = pixels;
end



function pix_pg_mask = get_pix_pg_mask(obj, abs_pix_indices, page_number)
% Get the min/max absolute index of the dirty page
min_idx = (page_number - 1)*obj.base_page_size + 1;
max_idx = min_idx + obj.base_page_size;

% Logical array tracking indices of abs_pix_indices that are in page_number
pix_pg_mask = abs_pix_indices >= min_idx & abs_pix_indices < max_idx;



function pix = read_clean_pix(obj, indices)
% Read the pixels at the given indices from the .sqw file backing obj
if issorted(indices, 'strictascend')
    % Check if indices is monotonically increasing (as assumed by
    % get_pix_at_indices), this is quicker than always sorting
    pix = obj.f_accessor_.get_pix_at_indices(indices);
else
    % Sort the pixel indices and remove duplicates, the idx_map provides
    % a way to map the indices back to their original order and
    % re-introduce the duplicates after the reading is complete
    [unique_sorted, ~, idx_map] = unique(indices);
    pix = obj.f_accessor_.get_pix_at_indices(unique_sorted);
    pix = pix(:, idx_map);
end
