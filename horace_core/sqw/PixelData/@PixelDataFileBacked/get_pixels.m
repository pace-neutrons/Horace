function pix_out = get_pixels(obj, abs_pix_indices,varargin)
% Retrieve the pixels at the given indices in the full pixel block,
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
%  Optional:
%  '-ignore_range'  -- if provided, new pix_object will not contain correct
%                      pixel ranges

% Output:
% -------
%   pix_out        Another PixelData object containing only the pixels
%                  specified in the abs_pix_indices argument.
%

abs_pix_indices = parse_args(obj, abs_pix_indices);

pix_out = PixelDataBase.create(read_clean_pix(obj, abs_pix_indices));


if obj.has_tmp_file || obj.page_edited
    % At least some pixels sit in temporary files

    % Allocate output array
    data_map = obj.get_memmap_handle();
    pix_out = PixelDataBase.create(double(data_map.data.data(:, abs_pix_indices)));

else

end

end

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
    error('HORACE:PixelData:get_pixels', ...
        'Pixel index out of range. Index must not exceed %i.', ...
        obj.num_pixels);
end

end

function is = is_positive_int_vector_or_logical_vector(vec)
is = isvector(vec) && (islogical(vec) || (all(vec > 0 & all(floor(vec) == vec))));
end

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

end
