function strout = to_head_struct_(obj,keep_data_arrays,data_only)
% Convert DND object into structure, convenient for observing using head
% method
%
% the fields are currently coinside with the fields, stored in old file
% format


[fields,data_fields] = DnDBase.head_form(keep_data_arrays);
if data_only
    fields = data_fields;
end

strout = struct();
for i=1:numel(fields)
    fls = fields{i};
    strout.(fls) = obj.(fls);
end
