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
%                    If not given, then the class name held in the input
%                   structure S is used.
%                    If the structure comes from a pre-serializable version of a
%                   class (so S does not contain the class name) then
%                   obj_template is used to give the output class type.
%                    Lastly, obj_template can be used to over-ride the class
%                   type held in the input structure S if it was created with
%                   to_struct acting on a serializable class. This is an
%                   uncommon scenario.
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
if isfield(S,'version') && S.version == obj.classVersion()
    % Structure was created by to_struct acting on the current version of a
    % serializable object
    if isfield (S, 'array_dat')
        obj = obj.from_bare_struct (S.array_dat);   % array of objects
    else
        obj = obj.from_bare_struct (S);     % scalar instance
    end
else
    % Structure was created from an earlier version of a serializable object, or
    % has a different provenance e.g. came from an older format that predates
    % the use of serializable
    obj = obj.from_old_struct (S);

end
