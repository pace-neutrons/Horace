function obj = from_class_struct_(obj,inputs)
% Restore object from the fields, previously obtained by to_struct method
%
% Input:
% inputs  -- structure or structure array of data, fully defining the
%            internal state of the object.
% Output:
% obj    --  fully defined object or array of objects, with contents
%            restored
%
nobj = numel(inputs);
if nobj>1
    obj = repmat(obj,size(inputs));
end

struct_fields = obj.indepFields();
for i=1:nobj
    obj(i) = set_obj(obj(i),inputs(i),struct_fields);
end
%
function obj = set_obj(obj,inputs,flds)
for i=1:numel(flds)
    fld = flds{i};
    val = inputs.(fld);
    if isstruct(val) && isfield(val,'serial_name')
        val = serializable.from_struct(val);
    end
    obj.(fld) = val;
end
