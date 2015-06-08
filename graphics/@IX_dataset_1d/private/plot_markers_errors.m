function plot_markers_errors (w)
% Plot markers and errorbars

line_width=get_global_var('genieplot','line_width');
marker_size=get_global_var('genieplot','marker_size');
marker_type=get_global_var('genieplot','marker_type');
color=get_global_var('genieplot','color');

nw = numel(w);
icol = mod(0:nw-1,length(color))+1;
isiz = mod(0:nw-1,length(marker_size))+1;
ityp = mod(0:nw-1,length(marker_type))+1;
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
    %custom_errorbars(x,signal,error,color,linestyle,linewidth,marker_type,marker_size)
    custom_errorbars(temp,w(i).signal,w(i).error,color{icol(i)},...
        'none',line_width(iwid(i)),marker_type{ityp(i)},marker_size(isiz(i)));
end

% Make linear or log axes as required
xscale=get_global_var('genieplot','xscale');
yscale=get_global_var('genieplot','yscale');
set (gca, 'XScale', xscale);
set (gca, 'YScale', yscale);
