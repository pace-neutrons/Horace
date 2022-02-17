function obj = check_and_set_angle_(obj,var_name,val,min_angle,max_angle)
if nargin<4
    min_angle = -360;
    max_angle  = 360;
end
if ~isnumeric(val) || val<min_angle || val>max_angle
    error('HORACE:ortho_instr_proj:invalid_argument',...
        'Variable %s should be numeric and belong to range [%d:%d], actually it is: %s',...
        var_name,min_angle,max_angle,evalc('disp(val)'))
end
obj.lattice.(var_name) = val;
%