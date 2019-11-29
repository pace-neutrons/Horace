function status = is_old_style_class(obj)
% Determine is a class isdefined in the pre-R2008a style
%
%   >> status = is_old_style_class(obj)

status = isempty(metaclass(obj));
