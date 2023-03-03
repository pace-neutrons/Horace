function  obj = check_angular_units_consistency_(obj)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here


if ~obj.img_range_set_
    old_val = obj.old_angular_unit_is_rad_;
    if ~isempty(old_val) && any(obj.angular_unit_is_rad_ ~= old_val)
        obj = convert_angular_ranges(obj,old_val,obj.angular_unit_is_rad_);
    end
end
range = obj.img_range;
% check if teta is in range [0; pi] and throw if the value is outside
% of this interval
check_angular_range(range(:,2),obj.angular_unit_is_rad_(1),[0 ,pi]);
% check if phi is in range [-pi; pi] and transform any other value into
% of this interval
check_angular_range(range(:,3),obj.angular_unit_is_rad_(2),[-pi,pi]);

% reset range_set and old_angular_units in c
obj.img_range_set_ = false;
obj.old_angular_unit_is_rad_ = [];



function check_angular_range(range,range_in_rad,limits_in_rad)
if range_in_rad
    limits = limits_in_rad;
else
    limits = rad2deg(limits_in_rad);
end
if range(1)<limits(1) || range(2)>limits(2)
    error('HORACE:spher_axes:invalid_argument', ...
        'Angular range: %s is outside of its alowed range: %s', ...
        mat2str(range),mat2str(limits));
end



function obj = convert_angular_ranges(obj,old_angles_in_rad,new_angles_in_rad)
% convert angular ranges from degree to radian or v.v. in case of
% the unit meaning have changed
for i=1:2
    if old_angles_in_rad(i)
        if ~new_angles_in_rad(i)
            obj.img_range_(:,1+i) = rad2deg(obj.img_range_(:,1+i));
        end
    else
        if new_angles_in_rad(i)
            obj.img_range_(:,1+i) = deg2rad(obj.img_range_(:,1+i));
        end
    end
end