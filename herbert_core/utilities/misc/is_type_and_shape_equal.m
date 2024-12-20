function [is,mess] = is_type_and_shape_equal(obj1,obj2,opt)
%COMPARE_TYPE_AND_SHAPE Part of generic procedure to compare objects in
%various classes.
%
%This procedure compares types and shapes of the objects and returns false
% if their types and shapes are different
%
is = true;
mess = '';
if ~isempty(opt)
    ignore_str = opt.ignore_str;
else
    ignore_str = false;
end
if ignore_str
    check_size = ~istext(obj1);
else
    check_size = true;
end
% Check array sizes match
if check_size && ~isequal(size(obj1), size(obj2))
    is = false;
    mess = sprintf("Different sizes. Size of first object is: [%s] and second is: [%s]", ...
        disp2str(size(obj1)),disp2str(size(obj2)));
    return
end
if isa(obj1,'function_handle') && isa(obj2,'function_handle')
    return
end

% Check that corresponding objects in the array have the same type
if isa(obj1,'matlab.mixin.Heterogeneous')
    for i = 1:numel(obj1)
        if ~isa(obj2(i),class(obj1(i)))
            elmtstr = '';
            if numel(obj1) > 1
                elmtstr = ['(element ', num2str(i), ')'];
            end
            is = false;
            mess = sprintf('Different types. First object: "%s" class: "%s" and second object: "%s" class: "%s"', ...
                elmtstr,class(obj1(i)),elmtstr,class(obj2(i)));

            return
        end
    end
else
    if ~isa(obj2(1),class(obj1(1)))
        is = false;
        mess = sprintf('Different types. First object: "%s" has class: "%s" and second object: "%s" class: "%s"', ...
            opt.name_a,class(obj1), opt.name_b,class(obj2));
    end
end