function new_figure = genie_figure_set_target (target)
% Set the current figure and current axes according to the requested plot target
%
% >> new_figure = genie_figure_set_target (target)
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
%   new_figure  True if a new figure had to be created to be the target.
%               False if an existing figure is the target.


% Define function to more strictly check graphics object
isscalargraphics = @(val,Type)(isscalar(val) && isgraphics(val,Type));

if isscalargraphics(target, 'axes')
    % Valid axes handle (i.e. handle to axes that have not been deleted)
    axes(target)    % set the target as the current axes
    new_figure = false;
    
elseif isscalargraphics(target, 'figure')
    % Valid figure handle (i.e. handle to a figure that has not been deleted)
    % This captures both a figure handle and a figure number
    figure(target)  % set target as the current figure
    new_figure = false;
    
elseif is_string(target)
    % Character string, so use as the name of a figure. The rules are:
    % - Name of a genie_figure (either already existing, or to be created).
    % - If there is a plot with that name that isn't genie_figure, use it as the
    %   target for the plot
    fig_name = strtrim(target);
    
    fig_handle = findobj('Type', 'figure', 'Name', fig_name);   % could be array
    [ok, is_current] = is_genie_figure (fig_handle);
    if isempty(fig_handle) || any(ok)
        % Either there is no figure with the target name, or there is at least
        % one which is also a genie_figure. 
        % - If there is no figure with the target name:
        %       - Create a new genie_figure with 'current' status and make it
        %         the plot target.
        % - In the second case, 
        %       - If they all have 'keep' status, create a new genie_figure, 
        %         give it 'current' status and make it the plot target
        %       - If there is a genie_figure with 'current' status, make it the
        %         plot target.
        fig_handle_current = fig_handle(is_current(ok));
        if isempty(fig_handle) || isempty(fig_handle_current)
            genie_figure_create(fig_name);
            new_figure = true;
        else
            figure(fig_handle_current);
            new_figure = false;
        end
    else
        % A figure exists with the name and it is not a genie_figure.
        % Make the most recently active figure with that name the current one
        % for plotting.
        figure(fig_handle(1))   % most recently active figure has index 1.
        new_figure = false;
    end
    
else
    error('HERBERT:graphics:invalid_argument', ...
        ['A target for plotting must be one of the following:\n', ...
        '- A character string (the figure name)\n', ...
        '- The figure number or figure handle of an existing figure\n', ...
        '- The axes handle of an existing set of axes'])
end
    