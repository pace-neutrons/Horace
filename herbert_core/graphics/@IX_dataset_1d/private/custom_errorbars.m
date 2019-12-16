function h=custom_errorbars(x,signal,error,color,linestyle,linewidth,...
    marker_type,marker_size)
% Custom errorbars function, plotting sighal with error and
% error-bars caps width set up to 0

% $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)

% Set errorbar cap lengths to zero
if verLessThan('matlab','8.4')
    h=errorbar(x,signal,error,'Color',color,...
        'LineStyle',linestyle,'LineWidth',linewidth,...
        'Marker',marker_type,'MarkerSize',marker_size);
    
    c=get(h,'children');xd=get(c(2),'XData');
    xd(4:9:end)=xd(1:9:end);xd(5:9:end)=xd(1:9:end);
    xd(7:9:end)=xd(1:9:end);xd(8:9:end)=xd(1:9:end);
    set(c(2),'XData',xd)
else
    % TODO! Should be better way of doing this, but it is currently unclear
    % how to set errorbar cap lengths to zero for Matlab V>=2014b in any
    % other way.
    h=plot(x,signal,'Color',color,...
        'LineStyle',linestyle,'LineWidth',linewidth,...
        'Marker',marker_type,'MarkerSize',marker_size);
    hold_state=ishold;
    
    hold 'on'
    ind = 1:numel(signal);
    errX = zeros(3*numel(signal),1);
    errY = zeros(3*numel(signal),1);
    errX(3*(ind -1)+1) = x(ind);
    errY(3*(ind -1)+1) = signal(ind)-error(ind);
    errX(3*(ind -1)+2) = x(ind);
    errY(3*(ind -1)+2) = signal(ind)+error(ind);
    errX(3*(ind -1)+3) = x(ind);
    errY(3*(ind -1)+3) = NaN;
    
    plot(errX,errY,'Color',color,'LineStyle','-','LineWidth',linewidth);
    
    if ~hold_state
        hold 'off'
    end
end

