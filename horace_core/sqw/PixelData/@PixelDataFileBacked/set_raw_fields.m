function  obj=set_raw_fields(obj, data, pix_fields, varargin)
%SET_RAW_PIXELS Update the data on the given pixel data fields
%
% The number of columns in 'data' must be equal to the number of fields in
% 'pix_fields'. The number of rows in 'data' must be equal to the number of
% elements in 'abs_pix_indices'.
%
% Examples:
% ---------
%
% Set all 'signal' and 'variance' to 1
%   >> obj.set_raw_fields(ones(2, 1), {'signal', 'variance'});
% Set the first 100 pixels' signal and variance to zero
%   >> obj.set_raw_fields(zeros(2, 100), {'signal', 'variance'}, 1:100);
%
% Input:
% ------
% data             The data with which to set the given fields.
% pix_fields       The name of a field, or a cell array of field names.
% abs_pix_indices  The indices to set data on. If not specified all indices are
%                  updated and 'size(data, 2)' must equal to obj.num_pixels.
%

[field_indices, abs_pix_indices] = parse_set_fields_args(obj, pix_fields, data, varargin{:});

if ~obj.read_only
    obj.f_accessor_.Data.data(field_indices, abs_pix_indices) = single(data);
else

    obj = obj.get_new_handle();
    obj.data_range = PixelDataBase.EMPTY_RANGE;
    % TODO: #975 loop have to be moved level up calculating image in single
    % TODO: Does this code makes any sense? Does it work?
    num_pages= obj.num_pages;
    for i = 1:num_pages
        obj.page_num = i;
        data = obj.data;

        [loc_indices, global_indices] = get_pg_idx_from_absolute_(obj, abs_pix_indices, i);

        data(field_indices, loc_indices) = data(global_indices);
        obj = obj.format_dump_data(data);
        obj.data_range = ...
            obj.pix_minmax_ranges(data, obj.data_range);

    end
    obj = obj.finish_dump();
end
