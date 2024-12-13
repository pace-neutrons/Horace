function iseq = eq (obj1, obj2)
% Return a logical variable stating if two serializable objects are equal or not
%
%   >> [iseq, mess] = eq (obj1, obj2)
%   >> [iseq, mess] = eq (obj1, obj2, p1, p2, ...)
%
% Input:
% ------
%   obj1        Object on left-hand side
%
%   obj2        Object on right-hand side
%
% See also equal_to_tol
[~,hash1] = build_hash(obj1);
[~,hash2] = build_hash(obj2);
iseq = strcmp(hash1,hash2);
