function [new_figure, w2, xlims, ylims, zlims] = genie_figure_parse_plot_args...
    (default_fig_name, new_axes, force_current_axes, ...
    w, w1_data_name, w2_ok, w2_data_name, lims_type, varargin)
% Parse the input arguments for plot functions and set target for plotting ouput.
% A new figure window may or may not have been created as the target.
%
%   >> [new_figure, w2, xlims, ylims, zlims] = genie_figure_parse_plot_args...
%    (default_fig_name, new_axes, force_current_axes, ...
%     w, w1_data_name, w2_ok, w2_data_name, lims_type)
%
% Optional arguments on the above:
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
% The target for plotting output is determined as follows:
%   - Generally, the output figure is a genie_figure with the name given by
%     default_fig_name:
%       - If there is a genie_figure with that name and which has 'current'
%         status, it will become the target. If not, a new genie_figure with
%         that name will be created, with 'current' status.
%       - The exception is if there happens to be a non-genie_figure with that
%         name; it will become the target. (This is an unusual circumstance that
%         will arise only by prior explicit construction of such a window by the
%         user.)
%
%   - If a figure name is provided using the keyword option 'name', all the
%     above applies but with the name provided with the option replacing
%     default_fig_name.
%
%   - If the keyword option 'name' is used to provide a figure handle or number,
%     it will become the target regardless of whether or not it is a 
%     genie_figure.
%   
%   On the target figure determined above:
%   - If new_axes is true, new axes will be drawn, replacing any existing axes.
%     If new_axes is false, existing axes, if there are any, will be retained 
%     together with any plots on those axes. If there are not any existing axes,
%     new ones will be created.
%
% The above is overridden if force_current_axes is true. In this case, the
% target is set to the current axes on the current figure. (Axes will be created
% if the current figure doesn't have any, and if there are no figures, a new
% genie_figure with name default_fig_name will be created.)
%
%
% Input:
% ------
%   default_fig_name
%               Default figure name if 'name' and 'axes' option(s) not given.
%               (note: the empty character vector '' is a valid figure name)
%
%   new_axes    True:  Draw the plot on new axes (replacing the existing axes on
%                     the target figure if necessary).
%               False: Overplot on existing axes on the target figure, if they
%                     are available; otherwise draw new axes.
%
%   force_current_axes
%               True:  Plot on the current axes of the current figure.
%               False: Plot target determined by default_fig_name, new_axes, and
%                      keyword value of option 'name' or 'axes'.
%
%               (note: new_axes and force_current_axes cannot both be true)
%
%   w           Primary plot data. 
%               Only needed if there is secondary data is permitted, that is, if
%               w_ok = true. Otherwise, can set w to e.g. []. 
%
%   w1_data_name  Name of primary data for error messages e.g. 'z-data'.
%                 Can be set to '' if secondary data is not permitted.
%
%   w2_ok       True:  Secondary data is permitted as an optional argument, but
%                      is not obligatory.
%               False: Secondary data is not permitted.
%
%   w2_data_name  Name of secondary data for error messages e.g. 'color data'
%                 Can be set to '' if secondary data is not permitted.
%
%   lims_type   Limits type:
%               'xy'    accept up to x-axis and y-axis limits
%               'xyz'   accept up to x-axis, y-axis and z-axis limits
%
%
%   Optional input arguments:
%   -------------------------
% Only permitted if w2_ok is true:
%     w2          Optional secondary data.
%
% Only permitted if new_axes is true:
%     xlo, xhi    x-axis lower and upper limits.
%
%     ylo, yhi    y-axis lower and upper limits.
%
%     zlo, zhi    z-axis lower and upper limits.
%
% Not permitted if force_current_axes:
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
%   new_figure  Logical scalar:
%               - true: a new figure was created to take the target plot
%               - false: the target is a previously existing window
%
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

% Check input format (failure e.g. misspelt keyword-value options)
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
if w2_ok
    if rem(numel(args),2)==1
        % An odd number of positional arguments is present, which is only
        % possible if secondary data is provided
        ioffset = 1;
        w2 = check_data_size (w, args{1}, w1_data_name, w2_data_name);
    else
        ioffset = 0;
        w2 = [];
    end
else
    % No secondary data permitted
    ioffset = 0;
    w2 = [];    % need to return a value
end

% Check the optional limits have correct format
if new_axes
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

% Set the plotting target
if force_current_axes
    % Force target to be current figure
    if ~isempty(get(groot,'CurrentFigure'))
        new_figure = genie_figure_set_target();
    else
        new_figure = genie_figure_set_target(default_fig_name);
    end
else
    % Select/create the plot target from the presence of 'name', 'axes', or
    % neither (in which case use the default_fig_name as the target)
    if present.name
        target = opt.name;
    elseif present.axes
        target = opt.axes;
    else
        target = default_fig_name;
    end
    new_figure = genie_figure_set_target (target);
end
