function [label,units_appended]=make_label(axis)
% Create axis annotation from IX_axis object. Always is a cellstr. Indicates if units string was appended.
%
%   >> [label,units_appended] = make_label(axis)

if ~isempty(axis.units)
    if ~isempty(axis.caption)
        label=axis.caption;
        label{end}=[axis.caption{end},' (',axis.units,')'];
    else
        label={['(',axis.units,')']};
    end
    units_appended=true;
else
    label=axis.caption;
    units_appended=false;
end
