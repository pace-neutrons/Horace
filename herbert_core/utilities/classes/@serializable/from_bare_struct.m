function obj = from_bare_struct (obj_template, S)
% Restore object or object array from a structure
%
%   >> obj = from_bare_struct (obj_template, S)
%
% Because the bare structure does not contain the information of the class type
% to be recovered, an object is needed to define it. This template object must
% be a serializable object.
%
% Typically obj_template will will simply be the object created by the
% constructor with no arguments for the class type to recover. (This use-case
% would only have required this method to have been a static method).
%
% However, there are circumstances when it might be convenient to have a source
% of extra fields other than the defaults for the empty constructor. In this
% case, obj_template is used to provide any properties that might be missing
% from the structure, in addition to defining the class type and the property
% names (via the class method saveableFields) to be set from S.
%
% OVERLOADING:
% ------------
% If the method "to_bare_struct" has been overloaded, then an overloaded version
% of this method will be required too.
%
%
% Input:
% ------
%   obj_template    Scalar instance of the class to be recovered.
%                   This is needed because the structure created by the method
%                  to_bare_struct does not contain the class type. The object
%                  is used to provide the class to be recovered, and the value
%                  of any missing properties if recovering from an older
%                  version.
%
%   S               Structure or structure array of data with the structure as
%                  created by the method to_bare_struct.
%                   Note that structures created by to_struct (i.e. with the
%                  fields 'serial_name', 'version' and (if from an array of
%                  objects) 'array_dat' are *NOT* valid.
%
% Output:
% -------
%   obj             Object or array of objects of the same class as the input
%                  argument obj_template.
%
%
% EXAMPLES
%   Suppose the variable my_obj is an array of IX_fermi_chopper
%   objects.
%   Simple case of saving to a bare structure, and recovering later:
%   >> S = to_bare_struct (my_obj);
%   >>      :
%   >> recovered_object_arr = from_bare_struct (S, IX_fermi_chopper)
%
%   Now suppose there is another class called IX_fancy_chopper that
%   has some properties in common with an IX_fermi_chopper. If the
%   additional state-defining properties of IX_fancy_chopper can be
%   taken as the the default on construction then it is valid to set
%
%   >> my_fancy_obj_arr = from_bare_struct (S, IX_fancy_chopper)
%
%   Suppose we have a valid instance of IX_fancy_chopper called
%   some_fancy_obj, then we can use it as a template from which to
%   set a collection of fields from the structure S
%
%   >> my_fancy_obj_arr = from_bare_struct (S, some_fancy_obj)
%  *OR*
%   >> my_fancy_obj_arr = some_fancy_obj.from_bare_struct (S)
%
%
% See also to_bare_struct

obj = from_bare_struct_ (obj_template, S);

end
