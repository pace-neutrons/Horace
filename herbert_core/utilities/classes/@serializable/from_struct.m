function obj = from_struct(obj,inputs)
% Restore object from the fields, previously obtained by struct method
% Input:
% inputs  -- structure or structure array of data, fully defining the
%            internal state of the object
% Output:
% obj    --  fully defined object or array of objects
%
struct_fields = fieldnames(inputs);
if numel(inputs)>1
    obj = repmat(obj,numel(inputs),1);
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
