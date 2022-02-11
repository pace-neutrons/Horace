function struc = to_struct_(obj,add_version)
% Convert serializable object into a special structure, which allow
% serialization and recovery using static "serializable.from_struct"
% operation.
%
% Inputs:
% obj -- the instance of the object to convert to a structure.
%        the fields to use
% Returns:
% struc -- structure, containing information, fully defining the
%          serializabe class
if nargin == 1
    add_version = false;
end

struc = obj.to_bare_struct(false);
if numel(obj)>1
    struc = struct('serial_name',class(obj),...
        'array_dat',struc);
else
    struc.serial_name = class(obj);
end
if add_version
    struc.version = obj.classVersion();
end
