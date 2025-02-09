function [fig_h, axes_h, plot_h] = plot_twod (w, alternate_cdata_ok, newplot, ...
    force_current_axes, plot_type, varargin)
% Make a plot of an IX_dataset_2d object or array of objects.
%
%   >> plot_twod (w, alternate_cdata_ok, newplot, force_current_axes, plot_type)
%   >> plot_twod (w, alternate_cdata_ok, newplot, force_current_axes, plot_type, wcol)
%
% With either of the above:
%   >> plot_twod (..., xlo, xhi)
%   >> plot_twod (..., xlo, xhi, ylo, yhi)
%   >> plot_twod (..., xlo, xhi, ylo, yhi, zlo, zhi)
%
% With any of the above:
%   >> plot_twod (..., 'name', fig)
%  or
%   >> plot_twod (..., 'axes', axes_handle)
%
% Output the figure, axes and handles to plot objects:
%   >> [fig_h, axes_h, plot_h] = plot_twod (...)
%
% The argument newplot and force_current_axes restrict which of the optional
% arguments are possible:
% - if newplot is false, then the plot ranges cannot be given
% - if force_current_axes is true, then 'name' or 'axes' cannot be given
%
%
% Input:
% ------
%   w           IX_dataset_2d object, or array of IX_dataset_2d objects:
%                   - The signal provides the z-data.
%
%   alternate_cdata_ok
%               If the plot type requires independent color-data (such as
%               plot type 'surface2'), then depending on the value of this flag:
%                False: 
%                   - The standard errors in w provide that color data
%                True:  
%                   - The standard errors in w provide that color data if there
%                     is no second argument wcol or it is empty.
%                   - The signal in wcol provides that data, if it is not empty.
%
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
%   plot_type   Type of plot to be drawn:
%                   'area'      area plot
%                   'surface'   surface plot
%                   'surface2'  surface plot where the first object sets
%                              the z-scale, and the seconds sets the colour
%                              scale.
%
% Optional arguments:
% 
%   wcol        If plotting z-axis and color scale independently:
%                   - IX_dataset_2d object or array of IX_dataset_2d objects
%                     the number of which and whose signal array size(s) match
%                     those the input argument w.
%                   - Any object or array of objects with a method sigvar that
%                     returns a signal array, and which satisfies the above size
%                     criteria.
%                   - Numeric array or cell array of numeric arrays that give
%                     the color data
%               If not needed to provide a separate source of color data, omit
%               wcol or set to [].
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
%                           
%  'axes', axes_handle  
%               Axes handle to be used as the target of the plot, if the axes
%               exist.
%
%   If neither 'name' nor 'axes' are given, then the user default figure name
%   available through the static data_plot_interface method default_name is
%   used, or if no default is given, the factory default hard-wired into this
%   function is used.


lims_type = 'xyz';
maxspec = 1000;     % maximum number of 2D datasets that can be plotted
default_fig_name = data_plot_interface.default_name();

plot_types={'area', 'surface', 'surface2'};


% Check input arguments
% ---------------------
% Check the number of datasets in the array is not too large
if numel(w) > maxspec
    error('HERBERT:graphics:invalid_argument', ...
        ['A maximum number of %s 2D datasets can be plotted at once.\n', ...
        'Check the size of the input object array'], num2str(maxspec))
end

% Get newplot argument
if islognumscalar(newplot)
    newplot = logical(newplot);   % in case numeric 0 or 1
else
    error('HERBERT:graphics:invalid_argument', ...
        'Input argument ''newplot'' must be logical true or false')
end

% Get force_current_axes argument
if islognumscalar(force_current_axes)
    force_current_axes = logical(force_current_axes);   % in case numeric 0 or 1
else
    error('HERBERT:graphics:invalid_argument', ...
        'Input argument ''force_current_axes'' must be logical true or false')
end

% Get plot type
if is_string(plot_type) && ~isempty(plot_type)
    ind = stringmatchi(plot_type, plot_types);
    if ~isempty(ind)
        plot_type = plot_types{ind};
    else
        error('HERBERT:graphics:invalid_argument', ...
            'Plot type ''%s'' is not recognised', plot_type);
    end
else
    error('HERBERT:graphics:invalid_argument', ...
        'Plot type must be a non-empty character string. It is ''%s''', ...
        disp2str(plot_type));
end

% Set the default figure name for the requested plot_type and configuration
% parameters for argument parsing
switch plot_type
    case 'area'
        if ~is_string(default_fig_name)
            default_fig_name = 'Herbert area plot';
        end
        alternate_cdata_ok = false;
        w1_data_name = '';
        w2_data_name = '';
    case 'surface'
        if ~is_string(default_fig_name)
            default_fig_name = 'Herbert surface plot';
        end
        alternate_cdata_ok = false;
        w1_data_name = '';
        w2_data_name = '';
    case 'surface2'
        if ~is_string(default_fig_name)
            default_fig_name = 'Herbert surface plot';
        end
        alternate_cdata_ok = true;
        w1_data_name = 'z-data';
        w2_data_name = 'color data';
end

% Parse the optional arguments and set the plot target
[wcol, xlims, ylims, zlims] = genie_figure_parse_plot_args (newplot, ...
    force_current_axes, lims_type, default_fig_name, ...
    w, alternate_cdata_ok, w1_data_name, w2_data_name, varargin{:});


% Perform plot
% ------------
% If newplot, delete any axes
if newplot
    delete(gca)     % not necessary if a new figure, but doesn't do any harm
else
    hold on;        % hold the existing plot for overplotting
end

% Plot data (already checked that it is valid)
switch plot_type
    case 'area'
        plot_area (w)
        box on                      % put boundary box on plot
        set(gca, 'layer', 'top')    % puts axes layer on the top
        
    case 'surface'
        if newplot
            view(3)                 % default line of sight for 3D if newplot
        end        
        plot_surface (w);
        set(gca, 'layer', 'top')    % puts axes layer on the top
        
    case 'surface2'
        if newplot
            view(3)                 % default line of sight for 3D if newplot
        end
        plot_surface2 (w, wcol);
        set(gca, 'layer', 'top')    % puts axes layer on the top
        
    otherwise
        error('HERBERT:graphics:invalid_argument', ...
            ['Logic error: unrecognised plot type ''%s''\n', ...
            'Please contact the developers.'], plot_type)     
end
hold off    % release plot (could have been held for overplotting, for example)


% If a newplot, add axes annotations, title, tick marks, change limits etc.
if newplot
    % Add axes annotations and title
    [tx, ty, tz] = make_label(w(1));    % Create axis annotations
    tt = w(1).title(:);
    % This may need to be MATLAB version specific:
    % tt = convertCharsToStrings(tt);
    if any(contains(tt, '$'))
        inter = 'latex';
    else
        inter = 'tex';
    end
    title(tt, 'FontWeight', 'normal', 'interpreter', inter);
    xlabel(tx);
    ylabel(ty); 
    if numel(axis()/2) > 3      % axis()/2 gives the number of axes of the plot
        zlabel(tz)
    end
    
    % Change ticks
    xticks = w(1).x_axis.ticks;
    if ~isempty(xticks.positions)
        set(gca, 'XTick', xticks.positions)
    end
    if ~isempty(xticks.labels)
        set(gca, 'XTickLabel', xticks.labels)
    end
    
    yticks = w(1).y_axis.ticks;
    if ~isempty(yticks.positions)
        set(gca, 'YTick', yticks.positions)
    end
    if ~isempty(yticks.labels)
        set(gca, 'YTickLabel', yticks.labels)
    end
    
    zticks = w(1).s_axis.ticks;
    if ~isempty(zticks.positions)
        set(gca, 'ZTick', zticks.positions)
    end
    if ~isempty(zticks.labels)
        set(gca, 'ZTickLabel', zticks.labels)
    end

    % Change limits if they are provided
    if isempty(xlims) && isempty(ylims) && isempty(zlims)
        axis tight  % might want to change the default for case of no limits?
    else
        axis tight
        if ~isempty(xlims)
            lx(xlims(1), xlims(2))
        end
        if ~isempty(ylims)
            lx(ylims(1), ylims(2))
        end
        if ~isempty(zlims)
            lx(zlims(1), zlims(2))
        end
    end
    
    % Add colorslider
    colorslider
end

% Get figure, axes and plot handles
[fig_h, axes_h, plot_h] = genie_figure_all_handles;
