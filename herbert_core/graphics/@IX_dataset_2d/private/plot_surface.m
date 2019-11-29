function plot_surface (w)
% Make surface plot

% Plot series of patch commands
nw = numel(w);

warning_printed=false;
plotted=false;
for i=1:nw
    if plotted; hold on; end   % hold on for array input
    if any(size(w(i).signal)<=1)
        if ~warning_printed
            disp('WARNING: One or more surfaces not plotted')
            disp('         Must have at least two points along the x and y axes to make a surface plot')
            warning_printed=true;
        end
    else
        [xv,yv,z]=prepare_for_surface(w(i).x,w(i).y,w(i).signal);
        surface(xv,yv,z,'facecolor','interp','cdatamapping','scaled','edgecolor','none');
        plotted=true;
    end
end

% Make linear or log axes as required
xscale=get_global_var('genieplot','xscale');
yscale=get_global_var('genieplot','yscale');
set (gca, 'XScale', xscale);
set (gca, 'YScale', yscale);
