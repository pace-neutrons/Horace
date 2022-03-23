function obj = recalculate_angular_units_values_(obj,old_val)
% change internal values from degree to radians if the angular units
% settings have changed

if obj.angular_is_degree_ == old_val
    return;
end
angular_values = {'psi_','omega_','dpsi_','gl_','gs_'};

for i=1:numel(angular_values)
    pn = angular_values{i};
    if obj.angular_is_degree_ % ancular changed to degree
        obj.(pn) = rad2deg(obj.(pn));
    else % angular changed to radians
        obj.(pn) = deg2rad(obj.(pn));
    end
end
