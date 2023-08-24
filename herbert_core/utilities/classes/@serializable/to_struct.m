function S = to_struct (obj)
% Convert a serializable object or array of objects into a dressed structure
%
%   >> S = to_struct (obj)
%
% To recover the input object, use the method from_struct.
%
% Uses the (potentially overloaded) public method to_bare_struct internally
% and adds additional field to hold the class name and version.
%
% The object is recursively explored to convert all properties which are
% serializable objects into structures using to_struct. Properties that are
% other objects remain as objects. Note that this means that if those objects
% have properties that are serializable, they will not be converted into
% structures.
%
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
%
% See also from_struct to_bare_struct from_bare_struct

S = to_struct_ (obj);

end
