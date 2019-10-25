function obj = check_and_set_units_(obj,units)
% Method verifies axis units and sets axis units if the value is valid
%
% Throws IX_axis:invalid_argument if units are invalid
%
%
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
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
