function obj = loadobj_(S,class_instance)
% Restore object from the data as they are stord on a hard drive
%
% Input: 
%  S      -- the structure, 
%
% Output:
% -------
%   obj     An instance of class_instance object or array of objects
%
ver_requested = class_instance.classVersion();
if isfield(S,'version')
    if S.version == ver_requested 
        S = rmfield(S,'version');
        if isfield(S,'array_data')
            obj = from_struct(class_instance,S.array_data);            
        else
            obj = from_struct(class_instance,S);
        end
    else
        obj = from_old_struct(class_instance,S);        
    end
else % previous version(s), written without version info or any old version
    obj = from_old_struct(class_instance,S);
end
