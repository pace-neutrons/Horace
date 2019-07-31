function obj = check_and_set_units_(obj,units)
% Method verifies axis units and sets axis units if the value is valid
%
% Throws IX_axis:invalid_argument if units are invalid
%
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)
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
