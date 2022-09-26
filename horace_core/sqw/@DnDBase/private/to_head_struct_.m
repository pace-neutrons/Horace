function strout = to_head_struct_(obj,keep_data_arrays)
% Convert DND object into structure, convenient for observing using head
% method

% the fields are currently coinside with the fields, stored in old file
% format
fields = {'filename','filepath','title','alatt','angdeg',...
    'offset','u_to_rlu','ulen','label',...
    'iax','iint','pax','p',...
    'dax','img_range'};
if keep_data_arrays
    fields = [fields(:);'s';'e';'npix'];
end

strout = struct();
for i=1:numel(fields)
    fls = fields{i};
    strout.(fls) = obj.(fls);
end
