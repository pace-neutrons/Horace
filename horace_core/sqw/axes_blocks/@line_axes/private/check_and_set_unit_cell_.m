function obj = check_and_set_unit_cell_(obj,val)

if ~isnumeric(val) || any(size(val) ~= [4,4])
    error('HORACE:line_proj:invalid_argument',...
        'unit cell should be defined by 4x4 matrix. It is: %s', ...
        disp2str(val))
end

vol3D = (cross(val(1:3,1),val(1:3,2))'*val(1:3,3));
if abs(vol3D)<1.e-8
    error('HORACE:line_proj:invalid_argument',...
        'the vector which define the cell volume are parallel or almost parallel to each other')
end
obj.unit_cell_ = val;