function data_out = get_fields(obj, pix_fields, varargin)
% GET_FIELDS Retrieve data for a field, or fields, for the given pixel indices in
% the full pixel block. If no pixel indices are given, the full range of pixels
% is returned.
%
% This method provides a convenient way of retrieving multiple fields
% of data from the pixel block. When retrieving multiple fields, the
% columns of data will be ordered corresponding to the order the fields
% appear in the inputted cell array.
%
%   >> sig_and_err = pix.get_fields({'signal', 'variance'})
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

[field_indices, abs_pix_indices] = parse_args(obj, pix_fields, varargin{:});

mmf = obj.f_accessor_;

if abs_pix_indices == obj.NO_INPUT_INDICES
    [pix_idx_start, pix_idx_end] = obj.get_page_idx_(obj.page_num_);
    data_out = double(mmf.Data.data(field_indices,pix_idx_start:pix_idx_end));
else
    data_out = double(mmf.Data.data(field_indices,abs_pix_indices));
end

end

function [field_indices, abs_pix_indices] = parse_args(obj, varargin)

parser = inputParser();
parser.addRequired('pix_fields', @(x) ischar(x) || iscellstr(x));
parser.addOptional('abs_pix_indices', obj.NO_INPUT_INDICES, @(x) isindex(x) || (istext(x) && x == "all"));
parser.parse(varargin{:});

pix_fields = parser.Results.pix_fields;
abs_pix_indices = parser.Results.abs_pix_indices;

if istext(abs_pix_indices) && abs_pix_indices == "all"
    abs_pix_indices = 1:obj.num_pixels;
end

pix_fields = cellstr(pix_fields);
obj.check_pixel_fields(pix_fields);
field_indices = cell2mat(obj.FIELD_INDEX_MAP_.values(pix_fields));

if abs_pix_indices ~= obj.NO_INPUT_INDICES
    if islogical(abs_pix_indices)
        abs_pix_indices = obj.logical_to_normal_index_(abs_pix_indices);
    end

    max_idx = max(abs_pix_indices);
    if max_idx > obj.num_pixels
        error('PIXELDATA:get_data', ...
            ['Pixel index out of range. Index must not exceed %i, ' ...
            'found %i'], obj.num_pixels, max_idx);
    end
end

end