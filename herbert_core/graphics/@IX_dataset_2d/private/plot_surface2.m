function plot_surface2 (w)
% Make surface plot

% Plot series of patch commands
if ~iscell(w), nw=numel(w); else nw=numel(w{1}); end
for i=1:nw
    if i==2; hold on; end   % hold on for array input
    if ~iscell(w)
        [xv,yv,z,c]=prepare_for_surface(w(i).x, w(i).y ,w(i).signal, w(i).error);
    else
        if ~isnumeric(w{2})
            [xv,yv,z,c]=prepare_for_surface(w{1}(i).x, w{1}(i).y, w{1}(i).signal, w{2}(i).signal);
        else
            [xv,yv,z,c]=prepare_for_surface(w{1}(i).x, w{1}(i).y, w{1}(i).signal, w{2});
        end
    end
    surface(xv,yv,z,c,'facecolor','interp','cdatamapping','scaled','edgecolor','none');
end

% Make linear or log axes as required
xscale=get_global_var('genieplot','xscale');
yscale=get_global_var('genieplot','yscale');
set (gca, 'XScale', xscale);
set (gca, 'YScale', yscale);
