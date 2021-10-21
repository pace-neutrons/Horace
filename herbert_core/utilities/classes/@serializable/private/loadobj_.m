function obj = loadobj_(S,obj_instance)
% Restore object from the data as they are stord on a hard drive
%
% Input:
%  S      -- the structure, returned by serialize class
%
%
% Output:
% -------
%   obj     An instance of class_instance object or array of objects
%
if nargin > 1
    obj = obj_instance;
else
    if ~isfield(S,'serial_name')
        error('HERBERT:serializable:invalid_argument',...
            ['Class has not been converted into a structure, using serializable',...
            ' class "to_struct" operation. This method can not restore the class'])
    end
    
    class_name = S.serial_name;
    obj = feval(class_name);
end
%
ver_requested = obj.classVersion();
if isfield(S,'version')
    if S.version == ver_requested        
        if isfield(S,'array_dat')
            obj = obj.from_class_struct(S.array_dat);
        else
            obj = obj.from_class_struct(S);
        end
    else
        obj = obj.from_old_struct(S);
    end
else % previous version(s), written without version info or any old version
    obj = obj.from_old_struct(S);
end
