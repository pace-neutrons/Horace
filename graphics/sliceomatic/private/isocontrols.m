function isocontrols(fig, onoff)
% Set up FIG to have an ISO surface controller on the bottom.
% ONOFF indicates if the controller is being turned ON or OFF
  
  d = getappdata(fig, 'sliceomatic');
  
  if onoff
    lim=[min(min(min(d.data))) max(max(max(d.data)))];
  
    set(d.axiso,'handlevisibility','on');
    set(fig,'currentaxes',d.axiso);
    set(d.axiso, 'xlim',d.clim,...
                 'ylim',[1 5],...
                 'clim',d.clim);
    image('parent',d.axiso,'cdata',1:64,'cdatamapping','direct',...
          'xdata',d.clim,'ydata',[0 5],...
          'alphadata',1.0, ...
          'hittest','off');
    title('Iso Surface Controller');
    set(d.axiso,'handlevisibility','off');
  else
    % Turn off the controller
    
    delete(findobj(d.axis,'type','image'));

  end