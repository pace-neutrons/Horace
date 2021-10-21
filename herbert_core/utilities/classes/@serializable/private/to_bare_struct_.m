function struc = to_class_struct_(obj)
% Convert serializable object into a special structure, which allow
% serialization and recovery using from_class_struct operation
%
% Inputs:
% obj -- the instance of the object to convert to a structure.
%        the fields to use
% Returns:
% struc -- structure, containing information, fully defining the
%          serializabe class
flds = indepFields(obj);

cell_dat = cell(numel(flds),numel(obj));
for j=1:numel(obj)
    for i=1:numel(flds)
        fldn = flds{i};
        val = obj(j).(fldn);
        if isa(val,'serializable') % else keep object as before. Serializer should handle it by its own way
            val= to_struct(val);
        end
        cell_dat{i,j} = val;
    end
end
struc = cell2struct(cell_dat,flds,1);
if numel(obj)>1
    struc = reshape(struc,size(obj));
end
%