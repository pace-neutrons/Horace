function obj = from_struct(obj,inputs)
% Restore object from the fields, previously obtained by struct method
%
struct_fields = fieldnames(inputs);
if numel(inputs)>1
    obj = repmat(obj,numel(inputs));
    for i=1:numel(inputs)
        obj(i) = set_obj(obj(i),inputs(i),struct_fields);
    end
    obj = reshape(obj,size(inputs));
else
    obj = set_obj(obj,inputs,struct_fields);
end
%
function obj = set_obj(obj,inputs,flds)
%
for i=1:numel(flds)
    fld = flds{i};
    obj.(fld) = inputs.(fld);
end
