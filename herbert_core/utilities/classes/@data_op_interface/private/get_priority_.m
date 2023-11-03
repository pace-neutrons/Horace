function [priority,sv_size,has_pix,has_img] = get_priority_(obj)
% GET_PRIORITY function returns a class priority which defines operations
% order.
%
% Input:
% obj   -- the object to check
% Outuput:
% priority  -- the number, which defines the priority of this
%              object operation within the list of all
%              operations
% sv_size   -- sigvar size of the object (size of its image)
% has_pix   -- true if object conains pixels
% has_img   -- true if the object is not a scalar (has image)
%

% All basic classes have basic priorities.
base_num = cellfun(@(x)isa(obj,x),data_op_interface.base_classes);
if ~any(base_num)
    error('HERBERT:data_op_interface:invalid_argument', ...
        'Class %s does not have Horace binary operation defined for it.', ...
        class(obj));
end
% basic class priority
priority = data_op_interface.bc_priority(base_num);
sv_size   = sigvar_size(obj);
if ~isequal(sv_size,[1,1]) % then sigvar size > 1 and this is image
    priority = priority+10;
    has_img = true;
else
    has_img = false;
end
if isa(obj,'sqw') && obj.has_pixels() || isa(obj,'PixelDataBase')
    has_pix = true;
    priority = priority + 100;
else
    has_pix = false;
end
