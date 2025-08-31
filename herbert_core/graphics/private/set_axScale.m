function set_axScale (axName, axScale)
% Change anaxis to a linear or log scale for the current and subsequent plots.
%
%   >> set_axScale (axName, axScale)
%
% Input:
% ------
%   axName      Axis name: 'X', 'Y' or 'Z'
%   axScale     One of 'linear' or 'log'

name = [upper(axName),'Scale'];

% Change for future plots
genieplot.set(name, axScale);

% Change current axes on the figure (if there is such a figure window and axes)
if ~isempty(get(groot,'CurrentFigure')) && ~isempty(get(gcf,'CurrentAxes'))
    set (gca, name, axScale);
end
