function data_out = get_data(obj, pix_fields, varargin)
% GET_DATA Retrieve data for a field, or fields, for the given pixel indices in
% the full pixel block. If no pixel indices are given, the full range of pixels
% is returned.
%
% This method provides a convenient way of retrieving multiple fields
% of data from the pixel block. When retrieving multiple fields, the
% columns of data will be ordered corresponding to the order the fields
% appear in the inputted cell array.
%
%   >> sig_and_err = pix.get_data({'signal', 'variance'})
%        retrieves the signal and variance over the whole range of pixels
%
%   >> run_det_id_range = pix.get_data({'run_idx', 'detector_idx'}, 15640:19244);
%        retrieves the run and detector IDs for pixels 15640 to 19244
%
% Input:
% ------
%   pix_fields       The name of a field, or a cell array of field names
%   abs_pix_indices  The pixel indices to retrieve, if not given, get full range.
%                    The syntax for these indices attempts to replicate indexing
%                    into a regular Matlab array. You can use logical indices
%                    as well as normal indices, and you can index into the array
%                    "out-of-order". However, you cannot use `end`, but it is
%                    possible to achieve the same effect using the `num_pixels`
%                    property.
%


NO_INPUT_INDICES = -1;
[pix_fields, abs_pix_indices] = parse_args(obj, pix_fields, varargin{:});
field_indices = cell2mat(obj.FIELD_INDEX_MAP_.values(pix_fields));

if abs_pix_indices == NO_INPUT_INDICES
    abs_pix_indices = 1:obj.num_pixels;
end

%% TODO: Check should go once SQW object defined and block-getters can locate pixeldata
if obj.has_tmp_file
    data_map = obj.get_memmap_handle();
    data_out = double(data_map.data.data(field_indices, abs_pix_indices));
else
    data_out = zeros(numel(field_indices), numel(abs_pix_indices));
    for i=1:obj.n_pages
        obj.load_page(i);
        [pg_idxs, data_idxs] = obj.get_pg_idx_from_absolute_(abs_pix_indices, i);

        if ~isempty(pg_idxs)
            data_out(:, data_idxs) = obj.data(field_indices, pg_idxs);
        end
    end
end

end

function [pix_fields, abs_pix_indices] = parse_args(obj, varargin)
    NO_INPUT_INDICES = -1;

    parser = inputParser();
    parser.addRequired('pix_fields', @(x) ischar(x) || iscell(x));
    parser.addOptional('abs_pix_indices', NO_INPUT_INDICES, ...
                       @is_positive_int_vector_or_logical_vector);
    parser.parse(varargin{:});

    pix_fields = parser.Results.pix_fields;
    abs_pix_indices = parser.Results.abs_pix_indices;

    pix_fields = cellstr(pix_fields);
    check_pixel_fields_(obj, pix_fields);

    if abs_pix_indices ~= NO_INPUT_INDICES
        if islogical(abs_pix_indices)
            abs_pix_indices = logical_to_normal_index_(obj, abs_pix_indices);
        end

        max_idx = max(abs_pix_indices);
        if max_idx > obj.num_pixels
            error('PIXELDATA:get_data', ...
                  ['Pixel index out of range. Index must not exceed %i, ' ...
                   'found %i'], obj.num_pixels, max_idx);
        end
    end
end


function is = is_positive_int_vector_or_logical_vector(vec)
    is = isvector(vec) && (islogical(vec) || (all(vec > 0 & all(floor(vec) == vec))));
end
