function output_struct = obj2struct(input)
% Recursively convert objects into a structures of the public properties
%
%   >> output_struct = obj2struct(obj)
%
% This function recursively resolves all objects into structures, keeping
% the public properties only.
%
% To retain the non-dependent properties only, both public and private,
% use <a href="matlab:help('obj2structIndep');">obj2structIndep</a>.
%
% The functionality is different to the Matlab intrinsic function struct,
% which returns all properties (public, private, hidden) as a structure,
% non-recursively and only for the first object in the array.
%
% Input:
% ------
%   obj             Object array or struct array
%
% Output:
% -------
%   output_struct   Struct array with the same size as the input object
%                  array, with the fields being the public properties.
%                   The function operates recursively, converting the
%                  public properties of any object into a structure
%
% See also obj2structIndep

public = true;
if isstruct(input) || isobject(input)
    output_struct = obj2struct_private(input,public);
else
    error('Input argument is not an object or a structure')
end
