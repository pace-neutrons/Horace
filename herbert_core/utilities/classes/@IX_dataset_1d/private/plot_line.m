function plot_line (w)
% Plot lines for an array of one-dimensional datasets

nw = numel(w);

% Get relevant plot item properties (colours, lines, markers)
color_cycle = genieplot.get('color_cycle');
colors = genieplot.get('colors');
line_styles = genieplot.get('line_styles');
line_widths = genieplot.get('line_widths');

% Set indices for cycling through plot properties
[icol, ilin, iwid] = property_index (nw, color_cycle, numel(colors), ...
    numel(line_styles), numel(line_widths));

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
    plot(xtemp, w(i).signal, 'Color', colors{icol(i)}, ...
         'LineStyle', line_styles{ilin(i)}, 'LineWidth', line_widths(iwid(i)));
end

