function obj=set_raw_fields(obj, data,pix_fields, varargin)
%SET_RAW_PIXELS Update the data on the given pixel data fields
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
% data             The data with which to set the given fields.
% pix_fields       The name of a field, or a cell array of field names.
% abs_pix_indices  The indices to set data on. If not specified all indices are
%                  updated and 'size(data, 2)' must equal to obj.num_pixels.
%
if ~exist('pix_fields', 'var')
    pix_fields = 'all';
end

NO_INPUT_INDICES = -1;

[field_indices, abs_pix_indices] = obj.parse_set_fields_args(pix_fields, data, varargin{:});

if isempty(abs_pix_indices)
    return;
end

obj.data_(field_indices, abs_pix_indices) = data;

end  % function