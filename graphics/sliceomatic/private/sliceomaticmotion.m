function sliceomaticmotion(fig,action)
% Handle generic motion events for the figure window.
  
  obj = hittest(fig);
  
  if ~isempty(obj)
    t = getappdata(obj,'motionpointer');
    cc = get(fig,'pointer');
  
    if t
      newc = t;
    else
      newc = get(0,'defaultfigurepointer');
    end
  
    if isa(newc,'char') && isa(cc,'char') && ~strcmp(newc,cc)
      setpointer(fig, newc);
    end
  end
  
  d = getappdata(fig,'sliceomatic');
  
  % need to do some checks in case multiple items are being plotted
  if ~isempty(d.motionmetaslice) && ishandle(d.motionmetaslice)
    p = ancestor(d.motionmetaslice,'figure');
  else
    p = [];
  end
  % we want to make sure that the axes we are using belongs to
  % the figure that called back
  % *** Replace:
  % [fig, axes, plot, other] = ixf_get_related_handles(handle);
  % *** with:
  axesH=get(fig,'CurrentAxes');
  
  if isempty(d.motionmetaslice) || ~ishandle(d.motionmetaslice) || p ~= fig
    d.motionmetaslice = line('vis','off',...
                             'linestyle','--',...
                             'marker','none',...
                             'linewidth',2,...
                             'erasemode','xor','clipping','off','parent',axesH);
    setappdata(fig,'sliceomatic',d);
  end

  if isempty(obj) || (obj ~= d.axx && obj ~= d.axy && obj ~= d.axz)
    set(d.motionmetaslice,'visible','off');
    return
  end
 
  aa = obj;
  apos=get(aa,'currentpoint');

  xl = xlim(axesH);
  yl = ylim(axesH);
  zl = zlim(axesH);
  
  if aa==d.axx || aa==d.axiso
    if aa==d.axiso
      % eh?
    else
      xdata = [ apos(1,1) apos(1,1) apos(1,1) apos(1,1) apos(1,1) ];
      ydata = [ yl(1) yl(2) yl(2) yl(1) yl(1) ];
      zdata = [ zl(2) zl(2) zl(1) zl(1) zl(2) ];
    end
  else
    % We are moving a Y or Z slice
    if aa==d.axy
      ydata = [ apos(1,2) apos(1,2) apos(1,2) apos(1,2) apos(1,2) ];
      xdata = [ xl(1) xl(2) xl(2) xl(1) xl(1) ];
      zdata = [ zl(2) zl(2) zl(1) zl(1) zl(2) ];
    else
      zdata = [ apos(1,2) apos(1,2) apos(1,2) apos(1,2) apos(1,2) ];
      ydata = [ yl(1) yl(2) yl(2) yl(1) yl(1) ];
      xdata = [ xl(2) xl(2) xl(1) xl(1) xl(2) ];
    end
  end

  set(d.motionmetaslice,'visible','on',...
                    'xdata',xdata,'ydata',ydata,'zdata',zdata);
