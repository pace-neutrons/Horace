function obj = check_and_set_units_(obj,units)
% Method verifies axis units and sets axis units if the value is valid
%
% Throws IX_axis:invalid_argument if units are invalid
%
%
% $Revision:: 830 ($Date:: 2019-04-08 16:16:02 +0100 (Mon, 8 Apr 2019) $)
%
if isempty(units)
    obj.units_ = '';
    return
end

if is_string(units)
    obj.units_ = units;
    return
end

error('IX_axis:invalid_argument','Axis units must be a character string');
