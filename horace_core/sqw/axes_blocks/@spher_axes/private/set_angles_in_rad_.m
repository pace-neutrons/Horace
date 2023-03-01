function obj = set_angles_in_rad_(obj,val)
%SET_ANGLES_IN_RAD main setter for angles_in_rad property.
%
% verify if inputs is acceptable and converts any acceptable form of input
% in two component logical vector, which defines if axis in angular direction
%
%
if isempty(val)
    obj.angles_in_rad_ = [false,false];
    return;
end
if issting(val)
    val = char(val);
end
if isnumeric(val)
    val = logical(val);
end
if numel(val)>2||numel(val)<1
    error('HORACE:spher_axes:invalid_argument',...
        'Angular units in rad property should have one or two elements. Attempt to set: %d', ...
        numel(val))
end
if ischar(val)
    val = arrayfun(@(i)convert_val_to_bool(val(i)),i=1:numel(val));
end
if numel(val)== 1
    val = [val,val];    
end
obj.angles_in_rad_ = val;



function bv = convert_val_to_bool(val)
if val=='r'
    bv = true;
else
    bv = false;
end