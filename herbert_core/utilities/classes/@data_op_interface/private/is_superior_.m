function [is,do_page_op,page_op_kind] = is_superior_(obj1,obj2)
% Helper function to establish order of operands in binary
% operations.
% is  -- true if class 2 is superior over class 1 and binary operations
%        should return class 2 as the result of operation instead of
%        class1 as it would normally occurs
% do_page_op
%     -- true if normal algorithm of performing operations
%        defined by sigvar.binary_op_manager is not working and
%        special page_op are used to perfrom operations.
% page_op_kind
%     -- depending on operands, three types of page op are
%        allowed namely object<->scalar object<->image and object<->object
%        0 means operations can be performed by converting to
%        sigvar.
%

% order of the object in the operation list
place_1 = cellfun(@(x)isa(obj1,x),data_op_interface.super_list);
place_2 = cellfun(@(x)isa(obj2,x),data_op_interface.super_list);
pos1 = find(place_1);
pos2 = find(place_2);

if isempty(pos1) || isempty(pos2)
    error('HERBERT:data_op_interface:invalid_argument', ...
        'Binary operations are not defined between classes %s and %s', ...
        class(obj1),class(obj2));
end
%
do_page_op = obj.force_flip(pos2)>0 || obj.force_flip(pos1)>0;
%
classname1 = class(obj1);
classname2 = class(obj2);
if strcmp(classname1,classname2)
    is = false;
    if isa(obj1,'sqw') && isa(obj2,'sqw')
        [is,page_op_kind] = is_sqw_superior(obj1,obj2);
    end
    return;
end
if pos2<pos1
    is = true;
    second_op_pos = pos1;
else
    is = false;
    second_op_pos = pos2;    
end
if do_page_op
    page_op_kind = data_op_interface.second_operand_type(second_op_pos);
else
    page_op_kind = 0;
end


function [is,page_op_kind] = is_sqw_superior(obj1,obj2)
% check order of operations for two sqw objects
obj1_has_pix = obj1.has_pixels();
obj2_has_pix = obj2.has_pixels();
if obj1_has_pix
    is = false;
else
    is = true;
end
if obj2_has_pix
    page_op_kind = 3; % sqw<->sqw
else
    page_op_kind = 2; % sqw<->img
end

