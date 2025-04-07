function plot_surface (w)
% Make a surface plot from an IX_dataset_2d object or array of objects


% Plot a series of calls to the surface function
nw = numel(w);

warning_printed=false;
plotted=false;
for i=1:nw
    if plotted
        hold on     % hold on for array input
    end   
    if any(size(w(i).signal)<=1)
        if ~warning_printed
            fprintf(2, ['WARNING: One or more surfaces not plotted.\n',...
                'Must have at least two points along the x and y axes ', ...
                'to make a surface plot.\n'])
            warning_printed=true;
        end
    else
        [xv,yv,z]=prepare_for_surface(w(i).x,w(i).y,w(i).signal);
        surface(xv,yv,z,'facecolor','interp','cdatamapping','scaled', ...
            'edgecolor','none');
        plotted=true;
    end
end
