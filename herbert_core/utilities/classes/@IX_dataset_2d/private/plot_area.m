function plot_area (w)
% Make an area plot from an IX_dataset_2d object or array of objects


% Plot a series of patch commands
nw = numel(w);

plotted=false;
for i=1:nw
    if plotted
        hold on     % hold on for array input
    end
    [xv,yv,z]=prepare_for_patch(w(i).x,w(i).y,w(i).signal);
    patch(xv,yv,z,'facecolor','flat','cdatamapping','scaled','edgecolor','none');
    plotted=true;
end

% Make linear or log axes as required
xscale=get_global_var('genieplot','xscale');
yscale=get_global_var('genieplot','yscale');
set (gca, 'XScale', xscale);
set (gca, 'YScale', yscale);
