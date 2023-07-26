function S = to_bare_struct (obj, varargin)
% Convert a serializable object or array of objects into a structure
%
%   >> S = to_bare_struct (obj)
%   >> S = to_bare_struct (obj, recursive_bare)
%   >> S = to_bare_struct (obj, '-recursive_bare')
%
% To recover the input object, use the method from_bare_struct.
%
% Uses independent properties obtained from method saveableFields on the
% assumption that the properties returned by this method fully define the public
% interface describing the state of the object.
%
% The object is recursively explored to convert all properties which are
% serializable objects into structures. Properties that are other objects remain
% as objects. Note that this means that if those objects have properties that
% are serializable, they will not be converted into structures.
%
% By default, properties that are serializable objects are recursively converted
% using the public method to_struct, which adds fields that contain the class
% name and version. To recursively force bare structures use the (deceptively
% ill-named option '-recursive_bare'. In that case, the public method
% to_bare_struct is used recursively.
%
% OVERLOADING:
% ------------
% In some complex class designs, it may be necessary to overload this method.
% In that case make sure that the inverse method from_bare_struct is also
% overloaded to invert the structure to the object.
%
%
% Input:
% ------
%   obj             Object or array of objects which are serializable i.e.
%                  which belong to a child class of serializable
%
% Optional:
%   recursive_bare  Logical true or false
%                       OR
% '-recursive_bare' Keyword; if present then recursive_bare is true
%
%                   Default if no option given: false
%
%                   If false, nested properties that are serializable objects
%                  are converted to structures using the public method
%                  to_struct. That is, they contain the information about the
%                  class name and version.
%                   If true, then they are converted to the bare structure using
%                  to_bare_struct.
%
% Output:
% -------
%   S               S is a structure array, each element of the array being the
%                  structure created from one object. The field names match the
%                  property names returned from the method saveableFields.
%
% See also from_bare_struct to_struct from_struct

if nargin>1
    if isnumeric(varargin{1})
        recursive_bare = logical(varargin{1});
    elseif islogical(varargin{1})
        recursive_bare = varargin{1};
    elseif ischar(varargin{1}) && strncmpi(varargin{1},'-r',2)
        recursive_bare = true;
    else
        recursive_bare = false;
    end
else
    recursive_bare = false;
end

S = to_bare_struct_ (obj, recursive_bare);

end
