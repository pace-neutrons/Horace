function isne = ne (obj1, obj2)
% Return a logical variable stating if two serializable objects are unequal or not
%
%   >> [iseq, mess] = ne (obj1, obj2)
%
% Input:
% ------
%   obj1        Object on left-hand side
%
%   obj2        Object on right-hand side
%
% Optional:
%   p1, p2,...  Any set of parameters that the equal_to_tol function accepts
%
% See also equal_to_tol

% TODO: can be done more efficiently as eq needs to check all
% the fields and ne may return when found first non-equal field

isne = ~eq(obj1,obj2);

