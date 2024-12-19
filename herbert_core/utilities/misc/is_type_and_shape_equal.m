function [is,mess] = is_type_and_shape_equal(obj1,obj2)
%COMPARE_TYPE_AND_SHAPE Part of generic procedure to compare objects in
%various classes. 
% 
%This procedure compares types and shapes of the objects and returns false
% if their types and shapes are different
%
is = true;
mess = '';

% Check array sizes match
if ~isequal(size(obj1), size(obj2))
    is = false;
    mess = sprintf("Sizes of lhs object is: %s and rhs object is: %s", ...
        disp2str(size(obj1),disp2st(size(obj2))));
    return
end

% Check that corresponding objects in the array have the same type
for i = 1:numel(obj1)
    if ~isa(obj2(i),class(obj1(i)))
        elmtstr = '';
        if numel(w1) > 1
            elmtstr = ['(element ', num2str(i), ')'];
        end
        is = false;
        mess = sprintf("lhs object %s class is: %s and rhs object %s class is: %s", ... 
            elmtstr,class(obj1(i)),elmtstr,class(obj2(i)));
        
        return
    end
end