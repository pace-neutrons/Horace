function [isne, mess] = ne (obj1, obj2, varargin)
% Return logical variable stating if two serializable objects are unequal or not
%
%   >> 

if nargout == 2
    [is, mess] = eq_ (obj1, obj2, varargin{:});
else
    is = eq_ (obj1, obj2, varargin{:});
end
isne = ~is;

end
