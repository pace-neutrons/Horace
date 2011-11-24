function label=make_label(axis)
% Create axis annotation from IX_axis object. Always is a cellstr.
%
%   >> label=make_label(axis)

if ~isempty(axis.units)
    if ~isempty(axis.caption)
        label=axis.caption;
        label{end}=[axis.caption{end},' (',axis.units,')'];
    else
        label={['(',axis.units,')']};
    end
else
    label=axis.caption;
end
