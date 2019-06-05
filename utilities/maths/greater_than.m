function status = greater_than (A,B)
% Generic routine to determine if one entity is greater than another
%
%   >> status = greater_than (A,B)
%
% For an equivalent routine that compares the indpendent properties
% (hidden, protected and public), use <a href="matlab:help('greater_thanIndep');"greater_thanIndep</a>
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
% that is, a method with name 'gt'.
%
% Objects of the same class are compared using a method that overloads '>',
% that is, a method with name 'gt'. If such a method does not exist for a
% particular object, then that object is resolved into a structure of the
% public properties using structPublic and comparison done on the contents
% of the fields. The process is continued until all nested structures and
% objects have been resolved.
%
% See also greater_thanIndep

public = true;
status = greater_than_private (A,B,public);
