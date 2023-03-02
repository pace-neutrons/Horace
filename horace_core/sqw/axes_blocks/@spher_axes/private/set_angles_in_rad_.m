function obj = set_angles_in_rad_(obj,val)
%SET_ANGLES_IN_RAD main setter for angles_in_rad property.
%
% verify if inputs is acceptable and converts any acceptable form of input
% in two component logical vector, which defines if axis in angular direction
% is expressed in angular units or radians.
%
%
old_val = obj.angles_in_rad_;
if isempty(val)
    obj.angles_in_rad_ = [false,false];
    if any(obj.angles_in_rad_ ~= old_val)
        obj = convert_angular_ranges(obj,old_val,obj.angles_in_rad_);
    end
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
obj.angles_in_rad_ = val;
%
if any(obj.angles_in_rad_ ~= old_val)
    obj = convert_angular_ranges(obj,old_val,obj.angles_in_rad_);
end


function bv = convert_val_to_bool(val)
if val=='r'
    bv = true;
else
    bv = false;
end

function obj = convert_angular_ranges(obj,old_angles_in_rad,new_angles_in_rad)
% method converts angular ranges from degree to radian and v.v. in case of
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