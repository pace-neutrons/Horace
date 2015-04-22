function plot_markers_errors_lines (w)
% Plot markers, errorbars, and lines

line_width=get_global_var('genieplot','line_width');
line_style=get_global_var('genieplot','line_style');
marker_size=get_global_var('genieplot','marker_size');
marker_type=get_global_var('genieplot','marker_type');
color=get_global_var('genieplot','color');

nw = numel(w);
icol = mod(0:nw-1,length(color))+1;
isiz = mod(0:nw-1,length(marker_size))+1;
ityp = mod(0:nw-1,length(marker_type))+1;
ilin = mod(0:nw-1,length(line_style))+1;
iwid = mod(0:nw-1,length(line_width))+1;
for i=1:nw
    if i==2; hold on; end   % hold on for array input
    nx=length(w(i).x);
    ny=length(w(i).signal);
    % plot data
    if (nx == ny)   % point data
        temp=w(i).x;
    else
        temp=0.5*(w(i).x(2:nx) + w(i).x(1:nx-1));
    end
    h=errorbar(temp,w(i).signal,w(i).error,'Color',color{icol(i)},...
          'LineStyle',line_style{ilin(i)},'LineWidth',line_width(iwid(i)),...
          'Marker',marker_type{ityp(i)},'MarkerSize',marker_size(isiz(i)));
    % Set errorbar cap lengths to zero
    c=get(h,'children');xd=get(c(2),'XData');
    xd(4:9:end)=xd(1:9:end);xd(5:9:end)=xd(1:9:end);
    xd(7:9:end)=xd(1:9:end);xd(8:9:end)=xd(1:9:end);
    set(c(2),'XData',xd)
end

% Make linear or log axes as required
xscale=get_global_var('genieplot','xscale');
yscale=get_global_var('genieplot','yscale');
set (gca, 'XScale', xscale);
set (gca, 'YScale', yscale);
