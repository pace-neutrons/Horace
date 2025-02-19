function plot_markers (w)
% Plot markers

marker_size=get_global_var('genieplot','marker_size');
marker_type=get_global_var('genieplot','marker_type');
color=get_global_var('genieplot','color');

nw = numel(w);

[color,icol]       = types_list_(color,'colors',nw);
[marker_type,ityp] = types_list_(marker_type,'marker_types',nw);
isiz = mod(0:nw-1,length(marker_size))+1;
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
    plot(temp,w(i).signal_,'LineStyle','none','Color',color{icol(i)},...
        'Marker',marker_type{ityp(i)},'MarkerSize',marker_size(isiz(i)));
end

% Make linear or log axes as required
XScale = genieplot.get('XScale');
YScale = genieplot.get('YScale');
set (gca, 'XScale', XScale);
set (gca, 'YScale', YScale);
