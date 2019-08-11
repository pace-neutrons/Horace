function angle = transform_and_get_angular_(obj,value)
% method checks if transformation into radians is defined and
% returns either value in degrees (as provided) or transformed
% into radians
if obj.angular_units_
    angle = value;
else
   angle  = value*obj.deg_to_rad_;
end

