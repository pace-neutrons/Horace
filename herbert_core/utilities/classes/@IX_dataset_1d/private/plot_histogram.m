function plot_histogram (w)
% Plot histograms for an array of one-dimensional datasets
% If point data, create faux bin boundaries steps halfway between the points

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
        hold on     % hold on for array input
    end
    
    % Construct x and y arrays for plotting histograms from the dataset
    x  = w(i).x;
    nx=length(x);
    ny=length(w(i).signal);
    xb=zeros(1,2*ny);    % x array for plotting histogram
    yb=zeros(1,2*ny);    % y array for plotting histograms
    
    if nx==ny       % point data
        if nx>1
            del0 = 0.5 * (x(2)-x(1));
            xb(1) = x(1) - del0;
            xb(2:2:2*ny-2) = 0.5 * (x(2:ny) + x(1:ny-1));
            xb(3:2:2*ny-1) = 0.5 * (x(2:ny) + x(1:ny-1));
            del1 = 0.5*(x(ny)-x(ny-1));
            xb(2*ny) = x(ny)+del1;
        elseif nx==1
            xb = x + [-0.5, 0.5];   % give it a false bin width of unity
        end
    else
        xb(1) = x(1);
        xb(2:2:2*ny-2) = x(2:ny);
        xb(3:2:2*ny-1) = x(2:ny);
        xb(2*ny) = x(nx);
    end
    
    yb(1:2:end) = w(i).signal;
    yb(2:2:end) = w(i).signal;
    
    % Plot data
    plot(xb, yb, 'Color', colors{icol(i)}, ...
        'LineStyle', line_styles{ilin(i)}, 'LineWidth', line_widths(iwid(i)));
end
