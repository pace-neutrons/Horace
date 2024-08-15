function obj = set_angles_in_rad_(obj,val)
%SET_ANGLES_IN_RAD main setter for angular_unit_is_rad property.
%
% verify if inputs is acceptable and converts any acceptable form of input
% in logical variable, which defines if axis in phi direction
% is expressed in degrees or radians.
%

obj.old_angular_unit_is_rad_ = obj.angular_unit_is_rad_;
if isempty(val)
    obj.angular_unit_is_rad_ = false;
    obj.type_(3) = 'd';
    return;
end
if isstring(val)
    val = char(val);
end
if isnumeric(val)
    val = logical(val);
end
if numel(val)~=1
    error('HORACE:cylinder_axes:invalid_argument',...
        'Angular units in rad property value should contain one element defining angular units in radians or degrees.\n Attempt to set: %d elements', ...
        numel(val))
end
if ischar(val)
    val = convert_val_to_bool(val);
end
%
obj.angular_unit_is_rad_ = val;
%
obj.type_(3) = convert_bool_to_val(val);
%

function ch = convert_bool_to_val(val)
if val
    ch = 'r';
else
    ch = 'd';
end

function bv = convert_val_to_bool(val)
if val=='r'
    bv = true;
else
    bv = false;
end
