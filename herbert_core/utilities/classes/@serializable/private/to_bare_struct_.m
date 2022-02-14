function struc = to_bare_struct_(obj,recursively)
% Convert serializable object into a special structure, which allow
% serialization and recovery using from_bare_struct operation
%
% Inputs:
% obj -- the instance of the object to convert to a structure.
%        the fields to use
% recursively -- if true, all serializable subobjects of the
%                class are converted to bare structure,
% add_version_to_subobjects -- if true, add class version to 
%                serializable subobjects, which are the children of the
%                current class version
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
            if recursively
                val= to_bare_struct_(val,recursively);
            else
                val= to_struct(val);
            end
        end
        cell_dat{i,j} = val;
    end
end
struc = cell2struct(cell_dat,flds,1);
if numel(obj)>1
    struc = reshape(struc,size(obj));
end
%