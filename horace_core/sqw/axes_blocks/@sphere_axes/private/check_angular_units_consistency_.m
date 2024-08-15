function  obj = check_angular_units_consistency_(obj)
% Verify if the spherical axes ranges consistent with the limits of the
% axes block and convert the limits into appropriate units if the limits
% have changed the units.


if ~obj.img_range_set_
    old_val = obj.old_angular_unit_is_rad_;
    if ~isempty(old_val) && any(obj.angular_unit_is_rad_ ~= old_val)
        obj = convert_angular_ranges(obj,old_val,obj.angular_unit_is_rad_);
    end
end
range = obj.img_range;
% check if theta is in range [0; pi] and phi in range [-pi,pi] and throw if
%  the value is outside of this interval
for i=1:2
    check_angular_range(range(:,1+i),obj.max_img_range_(:,1+i));
end

% reset range_set and old_angular_units in c
obj.img_range_set_ = false;
obj.old_angular_unit_is_rad_ = [];



function check_angular_range(range,limits)

if range(1)<limits(1) || range(2)>limits(2)
    error('HORACE:sphere_axes:invalid_argument', ...
        'Angular range: %s is outside of its alowed range: %s', ...
        mat2str(range),mat2str(limits));
end



function obj = convert_angular_ranges(obj,old_angles_in_rad,new_angles_in_rad)
% convert angular ranges from degree to radian or v.v. in case of
% the unit meaning have changed
for i=1:2
    if old_angles_in_rad(i)
        if ~new_angles_in_rad(i)
            obj.img_range_(:,1+i)     = rad2deg(obj.img_range_(:,1+i));
            obj.max_img_range_(:,1+i) = rad2deg(obj.max_img_range_(:,1+i));
        end
    else
        if new_angles_in_rad(i)
            obj.img_range_(:,1+i)     = deg2rad(obj.img_range_(:,1+i));
            obj.max_img_range_(:,1+i) = deg2rad(obj.max_img_range_(:,1+i));
        end
    end
end