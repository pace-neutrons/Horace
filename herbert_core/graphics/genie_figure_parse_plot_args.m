function [w2, xlims, ylims, zlims] = genie_figure_parse_plot_args...
    (newplot, force_current_axes, lims_type, default_fig_name, ...
    w, second_data_ok, w1_data_name, w2_data_name, varargin)
% Parse the input arguments for plot functions and set target for plotting
%
%   >> [w2, xlims, ylims, zlims] = genie_figure_parse_plot_args...
%    (newplot, force_current_axes, lims_type, default_fig_name, ...
%     w, w1_data_name, w2_data_name, second_data_ok)
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
%               Default figure name if 'name' and 'axes' option(s) not given.
%
%   w           Primary plot data. Can be [] if no secondary data is permitted,
%               that is, second_data_ok = false.
%
%   second_data_ok
%               True:  Secondary data is permitted as an optional argument, but
%                      is not obligatory.
%               False: Secondary data is not permitted.
%
%   w1_data_name  Name of primary data for error messages e.g. 'z-data'
%
%   w2_data_name  Name of secondary data for error messages e.g. 'color data'
%
%
% Optional input arguments:
% 
%   w2          Optional secondary data (only permitted if second_data_ok is
%               true).
%
%   xlo, xhi    x-axis lower and upper limits.
%
%   ylo, yhi    y-axis lower and upper limits.
%
%   zlo, zhi    z-axis lower and upper limits.
%
%  'name', fig  Fig is a figure name, figure number or figure handle.
%               
%               figure name: - If there is one or more genie_figures with the
%                              name, set the one with 'current' status as the
%                              target, or, if they all have 'keep' status,
%                              create a new genie_figure with the name and with
%                              'current' status.
%                            - If there are no genie_figures with the name but
%                              there are one or more plot with that name that
%                              aren't genie_figures, use the most recently
%                              active one as the target for the plot.
%                            - If there are no figures with the name, create a
%                              genie_figure with the name, give it 'current'
%                              status, and make it the target for the plot.
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
%   w2_out      Secondry data
%               - If none present: set to []
%               - If some present: w2_out = w2
%
%   xlims       [xlo, xhi] if valid limits
%               [] if not given or both were empty (indicating 'skip')
%
%   ylims       Same for ylo, yhi
%
%   zlims       Same for zlo, zhi


keyval = struct('name', [], 'axes', []);
[args, opt, present, ~, ok, mess] = parse_arguments(varargin, keyval);

% Check input format (failure e.g. mis-spelt keyword-value options)
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

% Check if secondary data is permitted, and if so, if it present.
if second_data_ok
    if rem(numel(args),2)==1
        % An odd number of postional arguments is present, which is only
        % possible if secondary data is provided
        ioffset = 1;
        w2 = check_data_size (w, args{1}, w1_data_name, w2_data_name);
    else
        ioffset = 0;
        w2 = [];
    end
else
    % No secondary data permitted
    w2 = [];    % need to return a value
    ioffset = 0;    
end

% Check the optional limits have correct format
if newplot
    [xlims, ylims, zlims, ok, mess] = check_plot_limits (lims_type, ...
        args{1+ioffset:end});
    if ~ok
        error('HERBERT:graphics:invalid_argument', mess)
    end
elseif isempty(args)
    xlims = [];
    ylims = [];
    zlims = [];
else
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
