function obj = recalculate_angular_units_values_(obj,old_val)
% change internal values from degree to radians if the angular units
% settings have changed

if obj.angular_is_degree_ == old_val
    return;
end
angular_values = {'angdeg_','psi_','omega_','dpsi_','gl_','gs_'};
if obj.angular_is_degree_ % ancular changed to degree
    mult = 1/obj.deg_to_rad_;
else % angular changed to radians
    mult = obj.deg_to_rad_;
end
for i=1:numel(angular_values)
    pn = angular_values{i};
    obj.(pn) = obj.(pn)*mult;
end
