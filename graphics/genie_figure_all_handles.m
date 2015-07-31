function [fig_handle, axes_h, plot_h, plot_type] = genie_figure_all_handles (fig)
% Get figure, axes and plot handles for current figure or named figure
%
%   >> [fig_h, axes_h, plot_h] = genie_figure_handles       % current figure
%   >> [fig_h, axes_h, plot_h] = genie_figure_handles (fig)
%
% Input:
% ------
%   fig         Figure name *OR* figure number *OR* figure handle.
%
%               An empty character string or one containing just whitespace
%              is a valid name: the name will be '' i.e. the empty string.
%
%               If fig is not given, or an empty argument apart from a
%              character string, returns figure handle for the current
%              figure, if one exists.
%
%               Normally fig would contain a single character string, or
%              scalar figure number or handle. However, you can give a
%              cell array of names, or array of nmbers or handles; these
%              sre effectivelly search options from which to find a single
%              instance. Likewise, note that there could be more than one
%              figure with the same name, which will then return an error.
%
% Output:
% -------
%   fig_h       Figure handle
%   axes_h      Axes handles
%   plot_h      Handles to plot objects that are line, patch, surface, or
%              hhgroup objects (the last is created by errorbar function)
%   plot_type   Corresponding type: 'line', 'patch', 'surface', or 'hhgroup'


% Determine figure handle
if ~exist('fig','var'), fig=[]; end
[fig_handle,ok,mess]=get_figure_handle_single(fig);
if ~ok
    error([mess,'; cannot return figure handles.'])
end

% Axes handle
axes_h=get(fig_handle,'CurrentAxes');
    
% Plot handle(s)
% We return plot handles to particular graphics objects that correspond to
% line, patch, surface and hhgroup (created by errorbar function, and used
% as of 2015-01-20, following G.S.Tucker)
h_children=get(axes_h,'children');
type_children=get(h_children,'type');
ok_plot_types={'line','patch','surface','hggroup'}; % hggroup == errorbar plot, added 2015-01-20, G.S.Tucker
isplot_h=false(size(h_children));
plot_type=cell(size(h_children));
for i=1:numel(ok_plot_types)
    ok_ind=strcmp(ok_plot_types{i},type_children);
    isplot_h=isplot_h | ok_ind;
    plot_type(ok_ind)=ok_plot_types(i);
end
plot_h=h_children(isplot_h);
plot_type=plot_type(isplot_h);
