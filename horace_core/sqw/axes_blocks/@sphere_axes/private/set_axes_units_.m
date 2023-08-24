function obj = set_axes_units_(obj,val)
%SET_AXES_UNITS main setter for axes_units property.
%
% verify if inputs is acceptable and converts any acceptable form of input
% in two component logical vector, which defines if axis in angular direction
% is expressed in angular units or radians.
%
%
if isstring(val)
    val = char(val);
end
if ~ischar(val)
    error('HORACE:sphere_axes:invalid_argument',...
        'Axes units should be a 4-character char array describing spherical axes units.\n Attempt to set: %s', ...
        disp2str(val));
end
if numel(val)<3||numel(val)>4
    error('HORACE:sphere_axes:invalid_argument',...
        'axes units should be 3 or 4 symbol text.\n Provided %s',...
        disp2str(val));
end
if numel(val) == 3
    val = [val,'e'];
end
arrayfun(@(i)check_type(obj,val(i),i),1:4);
obj.axes_units_ = val;
obj.do_check_combo_arg_ = false;
obj.angular_unit_is_rad = val(2:3);
obj.do_check_combo_arg_ = true;
%


function check_type(obj,val,i)
choice = obj.types_available_{i};
is  = ismember(val,choice);
if ~is
    error('HORACE:sphere_axes:invalid_argument',...
        'Symbol N%d of the axes units can be only %s. It is: %s',...
        i,disp2str(choice),val);
end

