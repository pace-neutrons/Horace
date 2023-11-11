function [flip,page_op_kind] = is_superior_(obj1,obj2,op_name)
% Helper function to establish order of operands in binary
% operations.
% flip -- true if class 2 is superior over class 1 and binary operations
%        should return class 2 as the result of operation instead of
%        class1 as it would normally occurs
% page_op_kind
%     -- depending on operands, three types of page op are
%        allowed namely object<->scalar object<->image and object<->object
%        0 means operations can be performed by converting to
%        sigvar.
%

% order of the object in the operation list
[priority1,sv_size1,has_pix1,has_img1] = data_op_interface.get_priority(obj1);
[priority2,sv_size2,has_pix2,has_img2] = data_op_interface.get_priority(obj2);

if ~(isequal(sv_size1,sv_size2) || isequal(sv_size1,[1,1]) || isequal(sv_size2,[1,1]))
    error('HERBERT:data_op_interface:invalid_argument', ...
        'Image size %s of operand 1 is inconsistent image size %s of operand 2 in operation %s', ...
        disp2str(sv_size1),disp2str(sv_size2),op_name);
end

if priority2 > priority1
    flip = true;
    op1_has_pix = has_pix2;
    op2_has_pix = has_pix1;
    op1_has_img = has_img2;
    op2_has_img = has_img1;
else
    flip = false;
    op1_has_pix = has_pix1;
    op2_has_pix = has_pix2;
    op1_has_img = has_img1;
    op2_has_img = has_img2;
end
page_op_kind = data_op_interface.get_operation_kind( ...
    op1_has_pix,op1_has_img,op2_has_pix,op2_has_img);