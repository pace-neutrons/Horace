function indices = check_pixel_fields_(obj, fields)
%CHECK_PIXEL_FIELDS_ Check the given field names are valid pixel data fields
% Raises error with ID 'HORACE:PIXELDATA:invalid_field' if any fields not valid.
%
%
% Input:
% ------
% fields    -- A cellstr of field names to validate.
%
% Output:
% indices   -- the indices corresponding to the fields
%

poss_fields = obj.FIELD_INDEX_MAP_;
bad_fields = ~cellfun(@poss_fields.isKey, fields);
if any(bad_fields)
    valid_fields = poss_fields.keys();
    error( ...
        'HORACE:PixelData:invalid_argument', ...
        'Invalid pixel field(s) {''%s''}.\nValid keys are: {''%s''}', ...
        strjoin(fields(bad_fields), ''', '''), ...
        strjoin(valid_fields, ''', ''') ...
        );
end

indices = cellfun(@(field) poss_fields(field), fields, 'UniformOutput', false);
indices = unique([indices{:}]);
end