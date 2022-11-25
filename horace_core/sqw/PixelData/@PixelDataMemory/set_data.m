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

if abs_pix_indices == NO_INPUT_INDICES
    if size(data,1) == obj.DEFAULT_NUM_PIX_FIELDS && ...
            ischar(pix_fields) && strcmp(pix_fields,'all')
        obj.raw_data_   = data; % all arguments have been already verified,
                                %            no point of using data_ setter
        obj.num_pixels_ = size(data,2);
    else
        obj.data_(field_indices, 1:end) = data;
    end
else
    obj.data_(field_indices, abs_pix_indices) = data;
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
