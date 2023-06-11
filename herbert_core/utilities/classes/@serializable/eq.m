function [iseq, mess] = eq (obj1, obj2, varargin)
% Return logical variable stating if two serializable objects are equal or not
%
%   >> 

% the generic equality operator, allowing comparison of
% serializable objects
%
% Inputs:
% other_obj -- the object or array of objects to compare with
% current object
% Optional:
% any set of parameters equal_to_tol function would accept

if nargout == 2
    [iseq, mess] = eq_(obj1, obj2, varargin{:});
else
    iseq = eq_ (obj1, obj2, varargin{:});
end

end
