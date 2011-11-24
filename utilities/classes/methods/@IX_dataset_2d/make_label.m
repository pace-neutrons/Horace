function [xlabel,ylabel,slabel]=make_label(w)
% Create axis annotations from IX_dataset_2d object. All outputs are cellstr.
%
%   >> [xlabel,ylabel,slabel]=make_label(w)

% If given array of objects, get labels for the first element

xlabel=make_label(w(1).x_axis);
ylabel=make_label(w(1).y_axis);
slabel=make_label(w(1).s_axis);

% Now address any distributions
str='';
if w(1).x_distribution && ~isempty(w(1).x_axis.units)
    str=[str,' / ',w(1).x_axis.units];
end
if w(1).y_distribution && ~isempty(w(1).y_axis.units)
    str=[str,' / ',w(1).y_axis.units];
end
if ~isempty(str)
    slabel{end}=[slabel{end},str];
end
