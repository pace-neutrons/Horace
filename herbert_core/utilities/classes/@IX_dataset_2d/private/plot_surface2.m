function plot_surface2 (w, wcol)
% Make a surface plot from an IX_dataset_2d object, or array of objects, with
% the color mapping from:
% - the standard errors of the IX_dataset_2d object(s);
%
% or, if the optional second argument is given, from:
% - the signal of any object, or array of objects, with a sigvar method;
% - a numeric array, or cell array of numeric arrays.


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
        if isempty(wcol)
            [xv,yv,z,c]=prepare_for_surface(w(i).x, w(i).y, w(i).signal, ...
                w(i).error);
        else
            if isobject(wcol)
                wcol_tmp = sigvar(wcol(i));
                [xv,yv,z,c]=prepare_for_surface(w(i).x, w(i).y, w(i).signal, ...
                    wcol_tmp.s);
            elseif iscell(wcol)
                [xv,yv,z,c]=prepare_for_surface(w(i).x, w(i).y, w(i).signal, ...
                    wcol{i});
            else
                [xv,yv,z,c]=prepare_for_surface(w(i).x, w(i).y, w(i).signal, ...
                    wcol);
            end
        end
        surface(xv,yv,z,c,'facecolor','interp','cdatamapping','scaled', ...
            'edgecolor','none');
        plotted=true;
    end
end

% Make linear or log axes as required
xscale=get_global_var('genieplot','xscale');
yscale=get_global_var('genieplot','yscale');
set (gca, 'XScale', xscale);
set (gca, 'YScale', yscale);
