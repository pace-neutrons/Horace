function set_data(obj, pix_fields, data, varargin)
%SET_PIXELS Update the data on the given pixel data fields
%
% The number of columns in 'data' must be equal to the number of fields in
% 'pix_fields'. The number of rows in 'data' must be equal to the number of
% elements in 'abs_pix_indices'.
%
% Examples:
% ---------
%
% Set the first 100 pixels' signal and variance to zero
%   >> set_data({'signal', 'variance'}, zeros(2, 100), 1:100);
%
% Input:
% ------
% pix_fields       The name of a field, or a cell array of field names.
% data             The data with which to set the given fields.
% abs_pix_indices  The indices to set data on. If not specified all indices are
%                  updated and 'size(data, 2)' must equal to obj.num_pixels.
%
NO_INPUT_INDICES = -1;

[field_indices, abs_pix_indices] = parse_args(obj, pix_fields, data, varargin{:});

base_pg_size = obj.base_page_size;

if abs_pix_indices == NO_INPUT_INDICES
    first_required_page = 1;
else
    first_required_page = ceil(min(abs_pix_indices)/base_pg_size);
end
obj.move_to_page(first_required_page);

set_page_data(obj, field_indices, data, abs_pix_indices);
while obj.has_more()
    obj.advance();
    set_page_data(obj, field_indices, data, abs_pix_indices);
end

end  % function


% -----------------------------------------------------------------------------
function [pix_fields, abs_pix_indices] = parse_args(obj, pix_fields, data, varargin)
    NO_INPUT_INDICES = -1;

    validateattributes(pix_fields, {'cell', 'char', 'string'}, {'nonempty'});
    validateattributes(data, {'numeric'}, {});

    parser = inputParser();
    parser.addOptional( ...
        'abs_pix_indices', ...
        NO_INPUT_INDICES, ...
        @(x) validateattributes(x, {'numeric', 'logical'}, {'integer', 'nonnegative'}) ...
    );
    parser.parse(varargin{:});
    abs_pix_indices = parser.Results.abs_pix_indices;

    pix_fields = cellstr(pix_fields);
    pix_fields = check_pixel_fields_(obj, pix_fields);

    if islogical(abs_pix_indices)
        abs_pix_indices = logical_to_normal_index_(obj, abs_pix_indices);
    end

    if size(data, 1) ~= numel(pix_fields)
        error( ...
            'HORACE:PixelData:invalid_argument', ...
            ['Number of fields in ''pix_fields'' must be equal to number ' ...
             'of columns in ''data''.\nn_pix_fields: %i n_data_columns: %i.'], ...
            numel(pix_fields), size(data, 1) ...
        );
    end
    if ~isequal(abs_pix_indices, NO_INPUT_INDICES) && size(data, 2) ~= numel(abs_pix_indices)
        error( ...
            'HORACE:PixelData:invalid_argument', ...
            ['Number of indices in ''abs_pix_indices'' must be equal to ' ...
            'number of rows in ''data''.\nFound %i and %i.'], ...
            numel(abs_pix_indices), size(data, 2) ...
        );
    end
end


function set_page_data(obj, field_indices, data, abs_indices)
    % Set the values on the given fields on the current page of data.
    NO_INPUT_INDICES = -1;
    base_pg_size = obj.base_page_size;

    if abs_indices == NO_INPUT_INDICES
        start_idx = (obj.page_number_ - 1)*base_pg_size + 1;
        end_idx = min(obj.page_number_*base_pg_size, obj.num_pixels);
        obj.data(field_indices, :) = data(:, start_idx:end_idx);
    else
        [pg_idxs, data_idxs] = get_pg_idx_from_absolute_( ...
            obj, abs_indices, obj.page_number_ ...
        );
        if ~isempty(pg_idxs)
            obj.data(field_indices, pg_idxs) = data(:, data_idxs);
        end
    end
end
