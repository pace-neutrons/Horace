function plot_errors (w)
% Plot error bars

line_width=get_global_var('genieplot','line_width');
color=get_global_var('genieplot','color');

nw = numel(w);
icol = mod(0:nw-1,length(color))+1;
iwid = mod(0:nw-1,length(line_width))+1;
for i=1:nw
    if i==2; hold on; end   % hold on for array input
    nx=length(w(i).x);
    ny=length(w(i).signal);
    %plot data
    if (nx == ny)           % point data
        temp=w(i).x;
    else
        temp=0.5*(w(i).x(2:nx) + w(i).x(1:nx-1));
    end
    h=errorbar(temp,w(i).signal,w(i).error,'Color',color{icol(i)},...
        'LineStyle','none','LineWidth',line_width(iwid(i)),...
        'Marker','none');
    % Set errorbar cap lengths to zero
    if verLessThan('matlab','8.4')
        c=get(h,'children');xd=get(c(2),'XData');
        xd(4:9:end)=xd(1:9:end);xd(5:9:end)=xd(1:9:end);
        xd(7:9:end)=xd(1:9:end);xd(8:9:end)=xd(1:9:end);
        set(c(2),'XData',xd)
    else
        %TODO! Should be better way of doing this
        %Its currently unclear how to
        % Set errorbar cap lengths to zero
        plot(temp,w(i).signal,'Color',color{icol(i)},...
            'LineStyle','none','LineWidth',line_width(iwid(i)),...
            'Marker','none');
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
