function h = custom_errorbars(x, signal, error, color, linestyle, linewidth,...
    marker_type, marker_size)
% Custom errorbars function, plotting signal with error bar cap width set to 0

% Set errorbar cap widths to zero
if verLessThan('matlab','9.1')
    % TODO! Should be better way of doing this, but it is currently unclear
    % how to set errorbar cap lengths to zero for Matlab 2016b>V>=2014b in any
    % other way.
    h = plot(x, signal, 'Color', color,...
        'LineStyle', linestyle, 'LineWidth', linewidth,...
        'Marker', marker_type, 'MarkerSize', marker_size);
    
    hold_state = ishold;
    hold 'on'
    
    ind = 1:numel(signal);
    errX = zeros(3*numel(signal),1);
    errY = zeros(3*numel(signal),1);
    errX(3*(ind -1)+1) = x(ind);
    errY(3*(ind -1)+1) = signal(ind)-error(ind);
    errX(3*(ind -1)+2) = x(ind);
    errY(3*(ind -1)+2) = signal(ind)+error(ind);
    errX(3*(ind -1)+3) = x(ind);
    errY(3*(ind -1)+3) = NaN;
    
    plot(errX, errY, 'Color', color, 'LineStyle', '-', 'LineWidth', linewidth);
    
    if ~hold_state
        hold 'off'
    end
    
else
    % Optional named value 'CapSize' introduced in MATLAB 2016b (v9.1)
    h = errorbar(x, signal, error, 'Color', color, ...
        'LineStyle', linestyle, 'LineWidth', linewidth,...
        'Marker', marker_type, 'MarkerSize', marker_size, 'CapSize', 0);
end
