function obj = from_struct (S, obj_template)
% Restore object or object array from a structure created by to_struct
%
%   >> obj = from_struct (S)
%   >> obj = from_struct (S, obj_template)
%
% Input:
% ------
%   S                Structure or structure array of data with the structure as
%                   created by the method to_struct.
%                    This could be from the current version of a serializable
%                   class, or from an earlier version of the class.
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
%
%
% See also to_struct


if nargin == 1
    obj = from_struct_ (S);
else
    obj = from_struct_ (S, obj_template);
end

end
