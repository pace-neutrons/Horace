function struc = to_struct_(obj,add_version)
% Convert serializable object into a special structure, which allow
% serialization and recovery using static "serializable.from_struct"
% operation.
%
% Inputs:
% obj         -- the instance of the object to convert to a structure.
%                the fields to use
% add_version -- if true, add version field to serializable subobjects
%                and the structure itself
% 
% Returns:
% struc -- structure, containing information, fully defining the
%          serializabe class

struc = to_bare_struct_(obj,false,add_version);
if numel(obj)>1
    struc = struct('serial_name',class(obj),...
        'array_dat',struc);
else
    struc.serial_name = class(obj);
end
if add_version
    struc.version = obj.classVersion();
end
