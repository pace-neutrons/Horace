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
    % Set errorbar cap lengths to zero
    if verLessThan('matlab','8.4')
        h=errorbar(temp,w(i).signal,w(i).error,'Color',color{icol(i)},...
            'LineStyle','none','LineWidth',line_width(iwid(i)),...
            'Marker',marker_type{ityp(i)},'MarkerSize',marker_size(isiz(i)));
        
        c=get(h,'children');xd=get(c(2),'XData');
        xd(4:9:end)=xd(1:9:end);xd(5:9:end)=xd(1:9:end);
        xd(7:9:end)=xd(1:9:end);xd(8:9:end)=xd(1:9:end);
        set(c(2),'XData',xd)
    else
        %TODO! Should be better way of doing this
        %Its currently unclear how to
        %Set errorbar cap lengths to zero
        plot(temp,w(i).signal,'Color',color{icol(i)},...
            'LineStyle','none','LineWidth',line_width(iwid(i)),...
            'Marker',marker_type{ityp(i)},'MarkerSize',marker_size(isiz(i)));
        hold(gca,'on')
        ind = 1:numel(w(i).signal);
        errX = zeros(3*numel(w(i).signal),1);
        errY = zeros(3*numel(w(i).signal),1);
        errX(3*(ind -1)+1) = temp(ind);
        errY(3*(ind -1)+1) = w(i).signal(ind)-w(i).error(ind);
        errX(3*(ind -1)+2) = temp(ind);
        errY(3*(ind -1)+2) = w(i).signal(ind)+w(i).error(ind);
        errX(3*(ind -1)+3) = temp(ind);
        errY(3*(ind -1)+3) = NaN;
        
        plot(errX,errY,'Color',color{icol(i)},...
            'LineStyle','-','LineWidth',line_width(iwid(i)))
        hold(gca,'off')
    end
end

% Make linear or log axes as required
xscale=get_global_var('genieplot','xscale');
yscale=get_global_var('genieplot','yscale');
set (gca, 'XScale', xscale);
set (gca, 'YScale', yscale);
