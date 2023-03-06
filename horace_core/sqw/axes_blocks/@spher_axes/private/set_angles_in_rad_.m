function obj = set_angles_in_rad_(obj,val)
%SET_ANGLES_IN_RAD main setter for angular_unit_is_rad property.
%
% verify if inputs is acceptable and converts any acceptable form of input
% in two component logical vector, which defines if axis in angular direction
% is expressed in angular units or radians.
%
%
obj.old_angular_unit_is_rad_ = obj.angular_unit_is_rad_;
if isempty(val)
    obj.angular_unit_is_rad_ = [false,false];
    return;
end
if isstring(val)
    val = char(val);
end
if isnumeric(val)
    val = logical(val);
end
if numel(val)>2||numel(val)<1
    error('HORACE:spher_axes:invalid_argument',...
        'Angular units in rad property value should contain one or two elements defining angular units in radians or degrees.\n Attempt to set: %d elements', ...
        numel(val))
end
if ischar(val)
    i=1:numel(val);
    val = arrayfun(@(i)convert_val_to_bool(val(i)),i);
end
if numel(val)== 1
    val = [val,val];
end
%
obj.angular_unit_is_rad_ = val;
%


function bv = convert_val_to_bool(val)
if val=='r'
    bv = true;
else
    bv = false;
end
