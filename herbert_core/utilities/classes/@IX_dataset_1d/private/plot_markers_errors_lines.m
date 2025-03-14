function plot_markers_errors_lines (w)
% Plot markers, errorbars, and lines for an array of one-dimensional datasets

nw = numel(w);

% Get relevant plot item properties (colours, lines, markers)
color_cycle = genieplot.get('color_cycle');
colors = genieplot.get('colors');
line_styles = genieplot.get('line_styles');
line_widths = genieplot.get('line_widths');
marker_types = genieplot.get('marker_types');
marker_sizes = genieplot.get('marker_sizes');

% Set indices for cycling through plot properties
[icol, ilin, iwid, ityp, isiz] = property_index (nw, color_cycle, numel(colors), ...
    numel(line_styles), numel(line_widths),...
    numel(marker_types), numel(marker_sizes));

% Loop over all datasets
for i=1:nw
    % Ensure axes are held for plotting an array of datasets
    if i==2
        hold on
    end
    
    % Get point positions
    x = w(i).x;
    nx = numel(x);
    ny = numel(w(i).signal);
    if nx==ny       % point data
        xtemp = x;
    else
        xtemp = 0.5*(x(2:nx) + x(1:nx-1));
    end

    % Plot data
    custom_errorbars(xtemp, w(i).signal, w(i).error, colors{icol(i)}, ...
        line_styles{ilin(i)}, line_widths(iwid(i)), ...
        marker_types{ityp(i)}, marker_sizes(isiz(i)));
end

% Make linear or log axes as required
XScale = genieplot.get('XScale');
YScale = genieplot.get('YScale');
set (gca, 'XScale', XScale);
set (gca, 'YScale', YScale);
