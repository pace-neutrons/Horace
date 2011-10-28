function plot_markers (w)
% Plot markers

%marker_size=get_global_var('genieplot','marker_size');
%marker_type=get_global_var('genieplot','marker_type');
%color=get_global_var('genieplot','color');
%
[marker_size,marker_type,color]=get(graph_config,'marker_size','marker_type','color');
%
nw = numel(w);
icol = mod(0:nw-1,length(color))+1;
isiz = mod(0:nw-1,length(marker_size))+1;
ityp = mod(0:nw-1,length(marker_type))+1;
for i=1:nw
    if i==2; hold on; end   % hold on for array input
    nx=length(w(i).x);
    ny=length(w(i).signal);
    % plot data
    if (nx == ny)   % point data
        plot(w(i).x,w(i).signal,'LineStyle','none','Color',color{icol(i)},...
            'Marker',marker_type{ityp(i)},'MarkerSize',marker_size(isiz(i)));
    else
        temp=0.5*(w(i).x(2:nx) + w(i).x(1:nx-1));
        plot(temp,w(i).signal,'LineStyle','none','Color',color{icol(i)},...
            'Marker',marker_type{ityp(i)},'MarkerSize',marker_size(isiz(i)));
    end
end

% Make linear or log axes as required
%xscale=get_global_var('genieplot','xscale');
%yscale=get_global_var('genieplot','yscale');
%
[xscale,yscale]=get(graph_config,'xscale','yscale');
%
set (gca, 'XScale', xscale);
set (gca, 'YScale', yscale);
 