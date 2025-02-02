function [xlims, ylims, zlims] = genie_figure_parse_plot_args...
    (newplot, force_current_axes, lims_type, default_fig_name, varargin)
% Parse the input arguments for plot functions and set target for plotting
%
%   >> [xlims, ylims, zlims] = genie_figure_parse_plot_args...
%    (newplot, force_current_axes, lims_type, default_fig_name)
%
% Optional aarguments on the above:
%   >> ... = genie_figure_plot_args (..., xlims)
%   >> ... = genie_figure_plot_args (..., xlims, ylims)
%   >> ... = genie_figure_plot_args (..., xlims, ylims, zlims)
%
% With any of the above:
%   >> ... = genie_figure_plot_args (..., 'name', fig)
%  or
%   >> ... = genie_figure_plot_args (..., 'axes', axes_handle)
%

% Input:
% ------
%   newplot     True:  Draw the plot on new axes (replacing existing axes on the
%                     target figure if necessary).
%               False: Overplot on existing axes on the target figure, if they
%                     are available.
%
%   force_current_axes
%               True:  Plot on the current axes of the current figure.
%               False: Plot on the current axes of the figure defined by the
%                     'name' or 'axes' options, or the default plot name if
%                      neither option is given.
%
%   lims_type   Limits type: 
%               'xy'    accept up to x-axis and y-axis limits
%               'xyz'   accept up to x-axis, y-axis and z-axis limits
%
%   default_fig_name
%               Default figure name for a 
%
% Optional arguments:
% 
%   xlo, xhi    x-axis lower and upper limits.
%
%   ylo, yhi    y-axis lower and upper limits.
%
%   zlo, zhi    z-axis lower and upper limits.
%
%  'name', fig  Fig is a figure name, figure number or figure handle.
%               
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
%  'axes', axes_handle  
%               Axes handle to be used as the target of the plot, if the axes
%               exist.
%               [If doesn't exist, throws an error]
%
% Output:
% -------
%   xlims       [xlo, xhi] if valid limits
%               [] if not given or both were empty (indicating 'skip')
%
%   ylims       Same for ylo, yhi
%
%   zlims       Same for zlo, zhi


keyval = struct('name', [], 'axes', []);
[args, opt, present, ~, ok, mess] = parse_arguments(varargin, keyval);

% Check input format (failure e.g. mis-spelt keywrod-value options)
if ~ok
    error('HERBERT:graphics:invalid_argument', mess)
end

% Check only one of 'name' and 'axes' options are present, or neither
if present.name && present.axes
    error('HERBERT:graphics:invalid_argument', ...
        'Cannot have both of the options ''name'' and ''axes'' present')
end

% Cannot have 'name' or 'axes' if forcing on current axes
if force_current_axes && (present.name || present.axes)
    error('HERBERT:graphics:invalid_argument', ...
        ['Options ''name'' and ''axes'' are not allowed if forcing the ', ...
        'plot on current axes'])
end

% Check the optional limits have correct format
if newplot
    [xlims, ylims, zlims, ok, mess] = check_plot_limits (lims_type, args{:});
    if ~ok
        error('HERBERT:graphics:invalid_argument', mess)
    end
elseif ~isempty(args)
    error('HERBERT:graphics:invalid_argument', ...
        'Explicitly setting the plot limits if overplotting is not permitted')
end

% Select/create the plot target from the presence of 'name', 'axes', or neither
% (in which case use the default_fig_name as the target)
if present.name
    target = opt.name;
elseif present.axes
    target = opt.axes;
else
    target = default_fig_name;
end
genie_figure_set_target (target);
