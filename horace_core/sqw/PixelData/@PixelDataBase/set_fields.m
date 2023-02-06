function obj=set_fields(obj, data,pix_fields, varargin)
%SET_FIELDS Update the data on the given pixel data fields
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

obj = obj.set_raw_fields(data,pix_fields, varargin{:});
obj = obj.reset_changed_coord_range(pix_fields);
