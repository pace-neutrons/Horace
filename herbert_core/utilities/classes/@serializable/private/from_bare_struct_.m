function obj = from_bare_struct_(obj,inputs)
% Restore object from the fields, previously obtained by to_struct method
%
% Input:
% inputs  -- structure or structure array of data, fully defining the
%            internal state of the object.
% check_validity - if true, check if the object build from the input
%            structure is valid using serializable validify methods
% Output:
% obj    --  fully defined object or array of objects, with contents
%            restored
%
nobj = numel(inputs);
if nobj>1
    obj = repmat(obj,size(inputs));
end
%--------------------------------------------------------------------------
% complex verification of intersection of input and output fields is
% necessary for supporting classes with variable field set depending on the
% state of the object. Also support inheritance, when partial object
% (parent) is restored from full child structure.
%
% The question if one should allow this to happen (e.g. heterogeneous
% arrays) remains open
fields_to_set = obj.saveableFields();
fields_present = fieldnames(inputs);
is_present = ismember(fields_to_set,fields_present);
if ~all(is_present)
    fields_to_set = fields_to_set(is_present);
end
%--------------------------------------------------------------------------
%
throw_on_invalid = obj(1).throw_on_invalid;
for i=1:nobj
    obj(i) = set_obj(obj(i),inputs(i),fields_to_set);
    if ~obj(i).isvalid
        % check interdependent properties again and if the object is still
        % invalid, throw exception
        [ok,mess,obj(i)] = obj(i).check_combo_arg();
        if ~ok && throw_on_invalid 
            error('HERBERT:serializable:runtime_error',mess);
        end
    end
end

end % function from_bare_struct_
%
function obj = set_obj(obj,inputs,flds)
for i=1:numel(flds)
    fld = flds{i};
    val = inputs.(fld);
    if isstruct(val)
        if  isfield(val,'serial_name')
           val = serializable.from_struct(val);
        end
    end
    obj.(fld) = val;
end
end % function set_obj
