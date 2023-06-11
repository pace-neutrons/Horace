function obj = from_struct_ (S, obj_template)
% Restore object or object array from a structure created by to_struct
%
%   >> obj = from_struct_ (S)
%   >> obj = from_struct_ (S, obj_template)
%
% Input:
% ------
%   S                Structure or structure array of data with the structure as
%                   created by the method to_struct.
%                    This could be from the current version of a serializable
%                   class, or an earlier version of the class.
%                    If the structure has a different form then an attempt is
%                   made to recover an object based on template object, if it is
%                   provided (see below). This will be the case when the
%                   structure has been read from file created before the class
%                   was made serializable.
%
% Optional:
%   obj_template     Scalar instance of the class to be recovered. It must be a
%                   serializable object.
%                    This is used to over-ride the class type held in the input
%                   structure S if it was created with to_struct acting on a
%                   serializable class.
%                    If S was not created by to_struct, then obj_template
%                   provides the template object into which to attempt to load
%                   the structure.
%
% Output:
% -------
%   obj             Object or array of objects with properties set from S.


% Check input
if nargin==1
    % No template object provided
    if isfield(S,'serial_name')
        % Structure was created by "to_struct"
        class_name = S.serial_name;
        obj = feval(class_name);
    else
        % Structure created by to_bare_struct; no source of class to recover
        error('HERBERT:serializable:invalid_argument',...
            ['Class has not been converted into a structure using serializable',...
            ' class "to_struct" operation. This method cannot restore the class'])
    end
else
    % Template object given. Over-ride any class name if S was created by
    % to_struct
    if numel(obj_template)~=1
        error('HERBERT:serializable:invalid_argument',...
            'The input template object must be a scalar instance')
    end
    obj = obj_template;
end


% Recover object
current_version = obj.classVersion();
if isfield(S,'version')
    % Structure was created by to_struct acting on a serializable object
    if S.version == current_version
        % Structure was created with current class version
        if isfield (S, 'array_dat')
            obj = obj.from_bare_struct (S.array_dat);   % array of objects
        else
            obj = obj.from_bare_struct (S);     % scalar instance
        end
    else
        % Structure has a different version; assume that we are trying to read
        % a structure created by an older version of the serializable class
        obj = obj.from_old_struct (S);
    end
else
    % Structure has a different provenance e.g. camefrom to_bare_struct_ or some
    % older format that predates the use of serializable
    obj = obj.from_old_struct (S);
end
