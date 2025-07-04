function [fig_h, axes_h, plot_h] = plot_oned (w, new_axes, ...
    force_current_axes, plot_type, varargin)
% Make a plot of an IX_dataset_1d object or array of objects.
%
%   >> plot_oned (w, new_axes, force_current_axes, plot_type)
%   >> plot_oned (..., xlo, xhi)
%   >> plot_oned (..., xlo, xhi, ylo, yhi)
%
% With any of the above:
%   >> plot_oned (..., 'name', fig)
%  or
%   >> plot_oned (..., 'axes', axes_handle)
%
% Output the figure, axes and handles to plot objects:
%   >> [fig_h, axes_h, plot_h] = plot_oned (...)
%
% The argument new_axes and force_current_axes restrict which of the optional
% arguments are possible:
% - if new_axes is false, then the plot ranges cannot be given
% - if force_current_axes is true, then 'name' or 'axes' cannot be given
%
%
% Input:
% ------
%   w           IX_dataset_1d object, or array of IX_dataset_1d objects
%
%   new_axes    True:  Draw the plot on new axes (replacing the existing axes on
%                     the target figure if necessary).
%               False: Overplot on existing axes on the target figure, if they
%                     are available; otherwise draw new axes.
%
%   force_current_axes
%               True:  Plot on the current axes of the current figure.
%               False: Plot target determined by new_axes, and keyword value of 
%                      option 'name' or 'axes'.
%
%               (note: new_axes and force_current_axes cannot both be true)
%
%   plot_type   Type of plot to be drawn:
%                   'e'     errors =  error bars
%                   'h'     histogram =  histogram plot
%                   'l'     line   =  line
%                   'm'     markers = marker symbols
%                   'd'     data   =  markers, error bars and lines
%                   'p'     points =  markers and error bars
%
% Optional arguments:
% 
%   xlo, xhi    x-axis lower and upper limits.
%
%   ylo, yhi    y-axis lower and upper limits.
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
%   If neither 'name' nor 'axes' are given, then the default figure name
%   is taken from the genieplot singleton property 'default_fig_name'. If that
%   property is set to [], then figure name hard-wired into this function is used.


lims_type = 'xy';
maxspec = genieplot.get('maxspec_1D');  % max number of datasets that can be plotted
default_fig_name = genieplot.get('default_fig_name');

plot_types = {'errors', 'histogram', 'line', 'markers', 'data', 'points'};


% Check input arguments
% ---------------------
% Check the number of datasets in the array is not too large
if numel(w) > maxspec
    error('HERBERT:graphics:invalid_argument', ...
        ['A maximum number of %s 1D datasets can be plotted at once. ', ...
        'Check the size of the input object array'], num2str(maxspec))
end

% Get new_axes argument
if islognumscalar(new_axes)
    new_axes = logical(new_axes);   % in case numeric 0 or 1
else
    error('HERBERT:graphics:invalid_argument', ...
        'Input argument ''new_axes'' must be logical true or false')
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
            'Plot type ''%s'' is not recognised',plot_type);
    end
else
    error('HERBERT:graphics:invalid_argument', ...
        'Plot type must be a non-empty character string. It is ''%s''', ...
        disp2str(plot_type));
end

% Set the default figure name for the requested plot_type
if ~is_string(default_fig_name)
    default_fig_name = 'Herbert 1D plot';   % all have the same default name
end

% Parse the optional arguments and set the plot target
w2_ok = false;
[new_figure, ~, xlims, ylims] = genie_figure_parse_plot_args (...
    default_fig_name, new_axes, force_current_axes, ...
    w, '', w2_ok, '', lims_type, varargin{:});


% Perform plot
% ------------
% Keep existing axes if an existing figure and new_axes not requested
keep_axes = (~new_figure && ~new_axes);
if keep_axes
    hold on;        % hold the existing plot for overplotting
else
    delete(gca)     % not necessary if a new figure, but doesn't do any harm
    box on          % plot default axes
end

% Plot data
switch plot_type
    case 'errors'
        plot_errors(w)
        
    case 'histogram'
        plot_histogram(w)
        
    case 'line'
        [frac, np] = w.calc_continuous_fraction();
        if frac<0.8
            warning('HERBERT:graphics:invalid_argument',...
                ['Your dataset contains NaNs and you are plotting %3.1f%% ',...
                'of your %d valid datapoints.\n', ...
                'Use pp/pm to see all your data points'], frac*100, np);
        end
        plot_line(w)
        
    case 'markers'
        plot_markers(w)
        
    case 'data'
        plot_markers_errors_lines(w)
        
    case 'points'
        plot_markers_errors(w)
        
    otherwise
        error('HERBERT:graphics:invalid_argument', ...
            ['Logic error: unrecognised plot type ''%s''\n', ...
            'Please contact the developers.'], plot_type)
end
hold off    % release plot (could have been held for overplotting, for example)


% If a not keeping axes, add axes annotations, title, tick marks, change limits etc.
if ~keep_axes
    % Add axes annotations and title
    [tx, ty] = make_label(w(1));    % Create axis annotations
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
    
    % Change ticks
    xticks = w(1).x_axis.ticks;
    if ~isempty(xticks.positions)
        set(gca, 'XTick', xticks.positions);
    end
    if ~isempty(xticks.labels)
        set(gca, 'XTickLabel', xticks.labels);
    end
    
    yticks = w(1).s_axis.ticks;
    if ~isempty(yticks.positions)
        set(gca, 'YTick', yticks.positions);
    end
    if ~isempty(yticks.labels)
        set(gca, 'YTickLabel', yticks.labels);
    end
    
    % Change limits if they are provided
    if isempty(xlims) && isempty(ylims)
        axis tight  % might want to change the default for case of no limits?
    else
        axis tight
        if ~isempty(xlims)
            lx(xlims(1), xlims(2))
        end
        if ~isempty(ylims)
            lx(ylims(1), ylims(2))
        end
    end

    % Make linear or log axes as required
    XScale = genieplot.get('XScale');
    YScale = genieplot.get('YScale');
    set (gca, 'XScale', XScale);
    set (gca, 'YScale', YScale);
end

% Get figure, axes and plot handles
[fig_h, axes_h, plot_h] = genie_figure_all_handles;
