function status = greater_thanIndep (A,B)
% Determine if one entity is greater than another comparing independent properties
%
%   >> status = greater_thanIndep (A,B)
%
% For an equivalent routine that compares the public object properties,
% use <a href="matlab:help('greater_than');"greater_than</a>
%
% An entity is deemed 'greater' if one of the following applies, in
% order:
% - Class name is longer
% - Class name is greater by Matlab comparison string1>string2
% - Number of dimensions of the array size
% - Larger extent along first dimension, second dimension,...
% - Recursive comparison until objects, cell arrays and structures are
%   resolved into numeric, logical or character comparisons
%
% Objects of the same class are compared using a method that overloads '>',
% that is, a method with name 'gt'. If such a method does not exist for a
% particular object, then that object is resolved into a structure of the
% independent properties (hidden, protected and public) using structIndep
% and comparison done on the contents of the fields. The process is
% continued until all nested structures and objects have been resolved.
%
% See also greater_than

public = false;
status = greater_than_private (A,B,public);
