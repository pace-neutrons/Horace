function iseq = eq (obj1, obj2)
% Return a logical variable stating if two serializable objects are equal or not
%
%   >> [iseq, mess] = eq (obj1, obj2)
%
% Input:
% ------
%   obj1        Object on left-hand side
%
%   obj2        Object on right-hand side
%
% See also equal_to_tol

% use generic overloadable methods to compare object's size and shape
% as they are overloadable and may be different for children
iseq = eq_to_tol_type_equal(obj1,obj2,'','');
if ~iseq
    return;
end
iseq  = eq_to_tol_shape_equal(obj1,obj2,'','',false);
if ~iseq
    return;
end

for i=1:numel(obj1)
    [~,hash1] = build_hash(obj1(i));
    [~,hash2] = build_hash(obj2(i));
    iseq = isequal(hash1,hash2);
    if ~iseq
        return;
    end
end
