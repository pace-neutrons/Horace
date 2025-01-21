function [fig_handle, axes_h, plot_h, plot_type] = genie_figure_all_handles (fig)
% Get the figure, axes and plot handles for a figure
%
%   >> [fig_h, axes_h, plot_h] = genie_figure_all_handles       % current figure
%   >> [fig_h, axes_h, plot_h] = genie_figure_all_handles (fig) % figure name/number/handle
%
% Throws an error if more than one than one figure is found with the same name.
%
% Input:
% ------
%   fig         Figure name *OR* figure number *OR* figure handle
%
%               An empty character string or one containing just whitespace
%              is a valid name: the name is '' i.e. the empty string.
%
%               If fig is not given, or is [], the function uses the current
%              figure as input, if one exists.
%
% Output:
% -------
%   fig_h       Figure handle
%               An error is thrown if no figure is found or more than one than
%              one figure is found.
%
%   axes_h      Axes handle to current axes on the figure. 
%               If none: axes_h is set to an empty graphics placeholder object.
%
%   plot_h      Column vector of handles to all child plot objects of the
%              current axes.
%               This might include, for example, line, patch, surface, errorbar
%              and hggroup objects. It may also include objects such as text or
%              rectangle objects that do not have any of XData, YData, Zdata and
%              CData.
%               If none: axes_h is set to an empty graphics placeholder object.
%
%   plot_type   Column cell array of the corresponding types of the child plot
%              objects, for example 'line', 'patch', 'surface', 'errorbar',
%              'hggroup' etc.


% Determine the figure handle - ensuring there is one and only one figure
% indicated by input argument fig (throws an error if otherwise)
if ~exist('fig', 'var')
    fig_handle = get_figure_handle('-single');  % current figure, if it exists
else
    fig_handle = get_figure_handle(fig, '-single');
end

% Get axes handle to current axes, if there are any
axes_h = get(fig_handle, 'CurrentAxes');
if isempty(axes_h)
    plot_h = gobjects(0);   % empty graphics placeholder object
    plot_type = [];
    return
end

% Get plot handle(s)
plot_h = get(axes_h, 'Children');
plot_type = get(plot_h, 'Type');
