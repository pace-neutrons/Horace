function plot_handle = plot_markers_errors (w)
% Plot markers and errorbars

line_width=get_global_var('genieplot','line_width');
marker_size=get_global_var('genieplot','marker_size');
marker_type=get_global_var('genieplot','marker_type');
color=get_global_var('genieplot','color');

nw = numel(w);
[color,icol]       = types_list_(color,'colors',nw);
[marker_type,ityp] = types_list_(marker_type,'marker_types',nw);
isiz = mod(0:nw-1,length(marker_size))+1;
iwid = mod(0:nw-1,length(line_width)) +1;
for i=1:nw
    if i==2; hold on; end   % hold on for array input
    x = w(i).x;
    nx=length(x);
    ny=length(w(i).signal_);
    if (nx == ny)   % point data
        temp=x;
    else
        temp=0.5*(x(2:nx) + x(1:nx-1));
    end
    plot_handle = custom_errorbars(temp,w(i).signal_,w(i).error_,color{icol(i)},...
        'none',line_width(iwid(i)),marker_type{ityp(i)},marker_size(isiz(i)));
end

% Make linear or log axes as required
xscale=get_global_var('genieplot','xscale');
yscale=get_global_var('genieplot','yscale');
set (gca, 'XScale', xscale);
set (gca, 'YScale', yscale);
