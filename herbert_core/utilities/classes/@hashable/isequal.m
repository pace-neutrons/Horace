function is  = isequal(obj1,varargin)
%ISEQUAL overload of standard isequal method to handle the case
% when one object has hash calculated and another one has not been calculated
% properly.
%
% We are interested in comparing two hashable only, so more arguments are
% handled by build-in implementation. This can be expanded if requested
%
if nargin>2
    is = builtin('isequal',obj1,varargin{:});
    return;
end
obj2 = varargin{1};
if      obj1.hash_defined && ~obj2.hash_defined
    obj1 = obj1.clear_hash();
elseif ~obj1.hash_defined &&  obj2.hash_defined
    obj2 = obj2.clear_hash();
end
is = builtin('isequal',obj1,obj2);