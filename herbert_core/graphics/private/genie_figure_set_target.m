function new_figure = genie_figure_set_target (target)
% Set the current figure and current axes according to the requested plot target
%
% >> 
%
% Input:
% ------
%   target      Target for plotting:
%               figure name: - Name of a genie_figure (either already existing,
%                              or to be created).
%                            - If there is a plot with that name that isn't a
%                              genie_figure, use it as the target for the plot.
%
%               figure number or handle:
%                            - If a figure with that number or handle already
%                              exists, use it as the target for the plot.
%                              [If doesn't exist, throws an error]
%
%               axes_handle: - Axes handle to be used as the target of the plot,
%                              if the axes exist.
%                              [If doesn't exist, throws an error]
%
% Output:
% -------
%   new_figure


if isgraphics(target, 'axes')
    % Valid axes handle (i.e. handle to axes that have not been deleted)
    axes(target)    % set the target as the current axes
    new_figure = false;
    
elseif is_string(target)
    % Character string, so use as the name of a figure. The rules are:
    % - Name of a genie_figure (either already existing, or to be created).
    % - If there is a plot with that name that isn't genie_figure, use it as the
    %   target for the plot
    fig_name = strtrim(target);
    
    fig_handle = findobj('Type', 'figure', 'Name', fig_name);   % could be array
    if isempty(fig_handle) || is_genie_figure(fig_handle(1))
        % No figure with the target name, or there is at least one and it is a
        % genie_figure. Set the 'current' status genie_figure to be the target
        % for plotting, or if they all have 'keep' status, create a new
        % genie_figure with the name, give it 'current' status and make it the
        % target for plotting
        new_figure = genie_figure_create(fig_name);
    else
        % A figure exists with the name and it is not a genie_figure.
        % Make the figure the current one for plotting.
        figure(fig_handle(1))   % most recently active figure of that name
        new_figure = false;
    end
    
elseif isgraphics(target, 'figure')
    % Valid figure handle (i.e. handle to a figure that has not been deleted)
    figure(target)  % set target as the current figure
    new_figure = false;

elseif isnumeric(target) && isscalar(target) && isgraphics(target, 'figure')
    % Valid figure number of a currently existing figure.
    % Note: the call to function isgraphics will return false if the input is
    % not an integer, not finite or less than unity, so no need to check all
    % these cases.
    figure(target)
    new_figure = false;
    
else
    error('HERBERT:graphics:invalid_argument', ...
        ['A target for plotting must be one of the following:\n', ...
        '- A character string (the figure name)\n', ...
        '- The figure number or figure handle of an existing figure\n', ...
        '- The axes handle of an existing set of axes'])
end
    