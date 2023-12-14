function S = to_struct_ (obj)
% Convert a serializable object or array of objects into a custom structure
%
%   >> S = to_struct_ (obj)
%
% Input:
% ------
%   obj      Object or array of objects which are serializable i.e. which belong
%           to a child class of serializable
%
% Output:
% -------
%   S        Structure with information sufficient to restore the object using
%           the method from_struct.
%
%           The structure has fields:
%               .serial_name        Name of the class
%               .version            Class version
%
%           and either:
%               .array_dat          Structure array each element of
%                                   the array being the structure
%                                   created from one object. The
%                                   field names match the property
%                                   names returned from the method
%                                   "saveableFields".
%           or there was only one object:
%               .<property_1>       First property in saveableFields()
%               .<property_2>       Second    "     "    "
%                     :                 :


% Convert to structure using public method to_bare_struct
% Several serializable classes overload to_bare_struct, so it would appear this
% is a deliberate design choice.
S = to_bare_struct (obj, false);

% Add fields that hold the class name and version number, and push the object
% data into a field called array_dat if the object is non-scalar
if isfield(S,'serial_name') || isfield(S,'version')
    error('HERBERT:serializable:invalid_argument',...
        ['The input object cannot have properties with the protected names:\n',...
        '''serial_name'' and ''version'''])
end

class_name = class(obj);
version = obj.classVersion();
if numel(obj)>1
    % Array of objects: object data is held in a field called 'array_dat'
    S = struct ('serial_name', class_name, 'version', version, 'array_dat', S);
else
    % Scalar object: hold object data at top level
    % Reorder fields so that serial_name and version are first
    % (replaces call to catstruct which is very expensive)
    S.serial_name = class_name;
    S.version = version;
    nf = numel(fieldnames(S));
    S = orderfields(S, [nf-1, nf, 1:nf-2]);
end
