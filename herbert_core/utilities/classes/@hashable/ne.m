function isneq = ne(obj1, obj2)
% Return a logical variable stating if two serializable objects are equal or not
%
%   >> isne = ne (obj1, obj2)
%
% Input:
% ------
%   obj1        Object on left-hand side
%
%   obj2        Object on right-hand side
%
% See also equal_to_tol

% sizes of objects are different
if ~all(size(obj1)==size(obj2))
    isneq = true;
    return;
end
isneq = false;
for i=1:numel(obj1)
    [~,hash1] = build_hash(obj1(i));
    [~,hash2] = build_hash(obj2(i));
    iseq = isequal(hash1,hash2);
    if ~iseq
        isneq = true;
        return;
    end
end
