function [is,mess] = eq_to_tol_(obj,other_obj,opt)
% Check equality of two ortho projections or two arrays of
% line_projections comparting the projection transformation
% instead of  all projection properties
%
% Different projection property values may define the same
% transformation, so the projections, which define the same
% transformation should be considered the equal.
%
% Inputs:
% obj       -- object or array of objects to compare
% other_obj -- the object or array of objects to compare with
%               current object
% opt       -- the structure, process_inputs_for_eq_to_tol returns

% Returns:
% is     -- True if the objects define the sampe pixel transformation and
%           false if not.
%
% mess   -- describing in more details where non-equality
%           occures (used in unit tests to indicate the details of an
%           inequality)

[is,mess] = eq_single(obj,other_obj,opt.name_a,opt.name_b,opt);
end

function [iseq,mess] = eq_single(obj1,obj2,name_a_val,name_b_val,opt)
% compare single pair of line_proj checking the transformation itself
%
if obj1.alatt_defined && obj1.angdeg_defined
    [q_to_img_1,shift_1,ulen1] = obj1.get_pix_img_transformation(4);
    obj1_undefined = false;
else
    obj1_undefined = true;
end
if obj2.alatt_defined && obj2.angdeg_defined
    [q_to_img_2,shift_2,ulen2] = obj2.get_pix_img_transformation(4);
    obj2_undefined = false;
else
    obj2_undefined = true;
end

if obj1_undefined && obj2_undefined
    opt.name_a = ['Undefined object: ',name_a_val];
    opt.name_b = ['Undefined object: ',name_a_val];

    [iseq,mess] = equal_to_tol(obj1.to_bare_struct(),obj2.to_bare_struct(),opt);
    return;
elseif obj1_undefined && ~obj2_undefined
    iseq = false;
    mess = sprintf('Object %s is undefined and Object %s is defined\n', ...
        name_a_val,name_b_val);
    return
elseif ~obj1_undefined && obj2_undefined
    iseq = false;
    mess = sprintf('Object %s is defined and Object %s is undefined\n', ...
        name_a_val,name_b_val);
    return
end
% both defined to compare them properly
opt.name_a = [name_a_val,'.q_to_img'];
opt.name_b = [name_b_val,'.q_to_img'];
[mat_eq,mess1] = equal_to_tol(q_to_img_1,q_to_img_2,opt);
if ~mat_eq
    mess1 = sprintf('Q_to_img: %s\n',mess1);
end
opt.name_a = [name_a_val,'.shift'];
opt.name_b = [name_b_val,'.shift'];

[shift_eq,mess2] = equal_to_tol(shift_1,shift_2,opt);
if ~shift_eq
    mess2 = sprintf('shift(s): %s\n',mess2);
end

[len_eq,mess3] = equal_to_tol(ulen1,ulen2, opt);
if ~len_eq
    mess3 = sprintf('ulen(s): %s\n',mess3);
end

iseq = mat_eq && shift_eq && len_eq;
mess = [mess1, mess2,mess3];
end