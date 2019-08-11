function output_struct = obj2structIndep(input)
% Recursively convert objects into a structures of the independent properties
%
%   >> output_struct = obj2structIndep(obj)
%
% This function recursively resolves all objects into structures, keeping
% the non-dependent properties only, both public and private.
%
% To retain the public properties only, both dependent and independent,
% use <a href="matlab:help('obj2struct');">obj2struct</a>.
%
% The functionality is different to the Matlab intrinsic function struct,
% which returns all properties (public, private, hidden) as a structure,
% non-recursively and only for the first object in the array.
%
% Input:
% ------
%   input           Object array or struct array
%
% Output:
% -------
%   output_struct   Struct array with the same size as the input object
%                  array, with the fields being the independent properties.
%                   The function operates recursively, resolving the
%                  public properties of objects and fields of structures
%
% See also obj2struct

public = false;
if isstruct(input) || isobject(input)
    output_struct = obj2struct_private(input,public);
else
    error('Input argument is not an object or a structure')
end
