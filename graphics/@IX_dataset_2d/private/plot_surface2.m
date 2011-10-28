function plot_surface2 (w)
% Make surface plot

% Plot series of patch commands
nw = numel(w);
for i=1:nw
    if i==2; hold on; end   % hold on for array input
    [xv,yv,z,c]=prepare_for_surface(w(i).x,w(i).y,w(i).signal,w(i).error);
    surface(xv,yv,z,c,'facecolor','interp','cdatamapping','scaled','edgecolor','none');
end

% Make linear or log axes as required
%xscale=get_global_var('genieplot','xscale');
%yscale=get_global_var('genieplot','yscale');
[xscale,yscale]=get(graph_config,'xscale','yscale');
%
set (gca, 'XScale', xscale);
set (gca, 'YScale', yscale);
