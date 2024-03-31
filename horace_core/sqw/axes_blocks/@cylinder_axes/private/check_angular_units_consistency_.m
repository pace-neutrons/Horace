function  obj = check_angular_units_consistency_(obj)
% Verify if the spherical axes ranges consistent with the limits of the
% axes block and convert the limits into appropriate units if the limits
% have changed the units.


if ~obj.img_range_set_
    old_val = obj.old_angular_unit_is_rad_;
    if ~isempty(old_val) && obj.angular_unit_is_rad_ ~= old_val
        obj = convert_angular_ranges(obj,old_val,obj.angular_unit_is_rad_);
    end
end
range = obj.img_range;
% check if phi is in range [-pi; pi] and transform any other value into
% this interval
check_angular_range(range(:,3),obj.max_img_range_(:,3));

% reset range_set and old_angular_units in c
obj.img_range_set_           = false;
obj.old_angular_unit_is_rad_ = [];



function check_angular_range(range,limits)
%
if range(1)<limits(1) || range(2)>limits(2)
    error('HORACE:cylinder_axes:invalid_argument', ...
        'Angular range: %s is outside of its alowed range: %s', ...
        mat2str(range),mat2str(limits));
end

function obj = convert_angular_ranges(obj,old_angles_in_rad,new_angles_in_rad)
% convert angular ranges from degree to radian or v.v. in case of
% the unit meaning have changed
if old_angles_in_rad
    if ~new_angles_in_rad
        obj.img_range_(:,3)     = rad2deg(obj.img_range_(:,3));
        obj.max_img_range_(:,3) = rad2deg(obj.max_img_range_(:,3));
    end
else
    if new_angles_in_rad
        obj.img_range_(:,3)     = deg2rad(obj.img_range_(:,3));        
        obj.max_img_range_(:,3) = deg2rad(obj.max_img_range_(:,3));
    end
end

