function [isne, mess] = ne (obj1, obj2, varargin)
% Return a logical variable stating if two serializable objects are unequal or not
%
%   >> [iseq, mess] = ne (obj1, obj2)
%   >> [iseq, mess] = ne (obj1, obj2, p1, p2, ...)
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


names = cell(2,1);
if nargout == 2
    names{1} = inputname(1);
    names{2} = inputname(2);
    [iseq, mess] = eq_ (obj1, obj2, nargout, names, varargin{:});
else
    iseq = eq_ (obj1, obj2, nargout, names, varargin{:});
end
isne = ~iseq;

end
