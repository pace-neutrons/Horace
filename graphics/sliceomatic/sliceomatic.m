function sliceomatic(U1,U2,U3,S,xlabel,ylabel,zlabel,xaxis,yaxis,zaxis,clim,isoflag)
% SLICEOMATIC - Slice and isosurface volume exploration GUI
%
% Using the GUI:
% -------------
% The white bars on the top, left, and right allow insertion of
% new slices on the X, Y, and Z planes.  Click in an empty area to
% add a new slice or surface.  Click on a control arrow to add a
% new slice or surface.
%
% The colored bar at the bottom is used to place and position an
% isosurface.  The color in the bar indicates a position (as seen
% in the slice) where the isosurface will go.
%
% When the rotate camera button is on, the popup menu will control
% the camera.  Turn off camera rotation in order to get individual
% control over properties of the slices and isosurfaces.
%
% The defaults menu provides default features of newly created
% slices and surfaces.  The AllSlices menu controls properties of
% all the slices and surfaces in the scene.  Use popup menus on the
% objects themselves, or the control arrows to change indivudual
% properties.
%
% If the data is very large, a reduced model of the data is created.
% This reduced data set is used for interactivly positioning
% isosurfaces.
%
% The Colormap popdown controls the currenlty active colormap.
% This map is used to color the slices.  The Alphamap popdown
% controls the alphamap used on the slices.
%
% Doing Cool Stuff:
% ----------------
%
% Exploration:
% You can get a quick feel of the current data set by adding a
% slice using the ColorTexture option.  Such a slice can be dragged
% through the data very quickly.
%
% Highlight an Area:
% If certain values in your data are interesting (very large, very
% small, or very median values) you can use transparency to make
% parts of your slices disappear.  Choose AlphaTexture options from
% the defaults, and sweep some slices across your data.  Use the
% AlphaMap to pick out certain data sets.  The exaple given here
% looks best with the `vdown' alphamap.
%
% You can also add a contour onto a slice to further extract shapes
% from the data you are exploring.
%
% Hidden Shapes:
% Use the isosurface control bar to create an isosurface.  Be
% patient with this control.  It often takes a while for the
% surface to be created.  Click and hold the mouse button down
% until the first surface appears.  Drag the surface through the
% values until you get something you like, then let go.  If your
% data set is very large, you will need to wait while the new and
% more accurate isosurface is created.
%
% Volumes:
% You can simulate a volume object by creating lots of stacked
% slices.  Simply use the proper Alphamap and transparent textures
% to highlight the correct data, and a large stack of slices will
% let you simulate a volume object.
%
% BUGS:
% ----
%
% 1) Sliceomatic does not use the `slice' command.  All slices are
%    created by explicitly extracting data from the volume.  As such,
%    only slices at integer values are allowed.
%
%
% See Also: SLICE, ISOSURFACE, ISOCAPS, CONTOURC, COLORMAP, SURFACE
%
% -------------------------------------------------------------------------
% RAL modificications to work on ISIS data
%   - Various modification by e-Science Team May 2003
%   - Addition modifications, T.G.Perring July 2005 - various quick fixes
%     to solve apparent inconsistencies with isosurfaces and slicing.
%
% Syntax:
%   >> sliceomatic (U1, U2, U3, S, xlabel, ylabel, zlabel,...
%                                       xaxis, yaxis, zaxis, clim, isoflag)
%
%   U1      Limits along x axis, [xlo, xhi]. The data are assumed
%          to be given on a uniformly spaced grid, with x values at
%          linspace(u1(1),u1(2),size(S,2))
%   U2      Limits along y axis (data at linspace(u1(1),u1(2),size(S,1))
%   U3      Limits along y axis (data at linspace(u1(1),u1(2),size(S,3))
%   S       Data values
%   xlabel  Label for x-axis slicer bar
%   ylabel  Label for y-axis slicer bar
%   zlabel  Label for z-axis slicer bar
%   xaxis   Annotation for x axis of plot
%   yaxis   Annotation for y axis of plot
%   zaxis   Annotation for z axis of plot
%   clim    Intensity limits
%   isoflag TRUE if isonormals are to be plotted later on. FALSE (or simply
%           omitted) if not. Isonormals take longer to calculate.

colordef white  % to avoid screw-up that earlier 'colordef none' produces

% *** Remove:
% IXG_ST_STDVALUES = ixf_global_var('libisis_graphics','get','IXG_ST_STDVALUES');

if nargin==0
    help sliceomatic
    return
end

if ~exist('isoflag','var')
    isoflag = false;
end

%-------------------------------------------------------------------------------------------------
% Fix following Alex Buts, 22/12/2012:
% Fixes problem on dual monitor systems. Need checks about negative side effects on other systems.
% Will reset just before exiting this function
mode = get(0, 'DefaultFigureRendererMode');
rend = get(0, 'DefaultFigureRenderer');
set(0, 'DefaultFigureRendererMode', 'manual');
set(0,'DefaultFigureRenderer','zbuffer');
%-------------------------------------------------------------------------------------------------

if isa(U1,'double')
    
    d.data=S;
    d.Xv=U1;
    d.Yv=U2;
    d.Zv=U3;
    d.xlabel=xlabel;
    d.ylabel=ylabel;
    d.zlabel=zlabel;
    d.xaxis=xaxis;
    d.yaxis=yaxis;
    d.zaxis=zaxis;
    d.clim=clim;
    isoHandles=[];
    
    %modified by srikanth on may 16th
    d.xlim=[min(min(min(U1)))  max(max(max(U1)))];
    d.ylim=[min(min(min(U2)))  max(max(max(U2)))];
    d.zlim=[min(min(min(U3)))  max(max(max(U3)))];
    % TGP: 27 July 2005: have adopted convention that U1, U2, U3 give limits
    % of data points, not bin boundaries
    deltax = (d.xlim(2)-d.xlim(1))/(size(S,2)-1);
    deltay = (d.ylim(2)-d.ylim(1))/(size(S,1)-1);
    deltaz = (d.zlim(2)-d.zlim(1))/(size(S,3)-1);
    d.xlim = d.xlim + [-deltax/2,deltax/2];
    d.ylim = d.ylim + [-deltay/2,deltay/2];
    d.zlim = d.zlim + [-deltaz/2,deltaz/2];
    d = sliceomaticfigure(d);
    d = sliceomaticsetdata(d,isoflag);
    
    
    setappdata(gcf,'sliceomatic',d);
else
    % Interpret commands
    d=getappdata(gcf,'sliceomatic');
    try
        switch U1
            
            %--------------------------Modification started on 16th may 2003-27th may by srikanth---------------
            case 'ISONew1'
                %           I=U2;
                %           d.clim(1,1)=I;
                d.clim=U2;    % replace above two lines - TGP 28 July 2005
                set(d.axmain,'clim',d.clim);
                set(d.axiso, 'xlim',d.clim,...
                    'ylim',[1 5],...
                    'clim',d.clim);
                image('parent',d.axiso,'cdata',1:64,'cdatamapping','direct',...
                    'xdata',d.clim,'ydata',[0 5],...
                    'alphadata',1.0, ...
                    'hittest','off');
                sliceomatic('isodeleteall')
                
            case 'ISONew2'
                %           I=U2;
                %           d.clim(1,2)=I;
                d.clim=U2;    % replace above two lines - TGP 28 July 2005
                set(d.axmain,'clim',d.clim);
                set(d.axiso, 'xlim',d.clim,...
                    'ylim',[1 5],...
                    'clim',d.clim);
                image('parent',d.axiso,'cdata',1:64,'cdatamapping','direct',...
                    'xdata',d.clim,'ydata',[0 5],...
                    'alphadata',1.0, ...
                    'hittest','off');
                sliceomatic('isodeleteall')
                %--------------------------Modification started on 12th  may 2003 by srikanth---------------
            case 'XnewText'
                X=U2;
                xdivisions=(size(d.data,2)-1);
                xdivisions=(d.xlim(2)-d.xlim(1))/xdivisions;
                nXDIV=((X-d.xlim(1))/xdivisions)+1;
                newXVal=round(nXDIV);
                newXVal=d.xlim(1)+(newXVal)*xdivisions;
                h=findobj(gcf,'Tag','slice_u1');
                set(h,'string',num2str(newXVal));
                if(X==0)
                    newa=arrow(d.axx,'down',[X+0.001 0]);
                else
                    newa=arrow(d.axx,'down',[X 0]);
                end
                set(gcf,'currentaxes',d.axmain);
                new=localslice(d.data, nXDIV, [], []);
                setappdata(new,'controlarrow',newa);
                setappdata(newa(2),'arrowslice',new);
                set(new,'alphadata',get(new,'cdata'),'alphadatamapping','scaled');
                set(newa,'buttondownfcn','sliceomatic Xmove');
                set([new newa],'uicontextmenu',d.uic);
                % Make sure whatever buttonupfcn on the figure is run now to "turn
                % off" whatever was going on before we got our callback on the
                % arrow.
                buf = get(gcf,'windowbuttonupfcn');
                if ~strcmp(buf,'')
                    eval(buf);
                end
                d.draggedarrow=newa(2);
                dragprep(newa(2));
                setpointer(gcf,'SOM leftright');
                set(d.motionmetaslice,'visible','off');
                dragfinis(d.draggedarrow);
                
            case 'YnewText'
                Y=U2;
                ydivisions=(size(d.data,1)-1);
                ydivisions=(d.ylim(2)-d.ylim(1))/ydivisions;
                nYDIV=((Y-d.ylim(1))/ydivisions)+1;
                if(Y==0)
                    newa=arrow(d.axy,'right',[0 Y+0.0001]);
                else
                    newa=arrow(d.axy,'right',[0 Y]);
                end
                newYVal=round(nYDIV);
                newYVal=d.ylim(1)+(newYVal-1)*ydivisions;
                h=findobj(gcf,'Tag','slice_u2');
                set(h,'string',num2str(newYVal));
                
                set(gcf,'currentaxes',d.axmain);
                new=localslice(d.data, [], nYDIV, []);
                
                setappdata(new,'controlarrow',newa);
                setappdata(newa(2),'arrowslice',new);
                set(new,'alphadata',get(new,'cdata'),'alphadatamapping','scaled');
                set(newa,'buttondownfcn','sliceomatic Ymove');
                set([new newa],'uicontextmenu',d.uic);
                % Make sure whatever buttonupfcn on the figure is run now to "turn
                % off" whatever was going on before we got our callback on the
                % arrow.
                buf = get(gcf,'windowbuttonupfcn');
                if ~strcmp(buf,'')
                    eval(buf);
                end
                d.draggedarrow=newa(2);
                dragprep(newa(2));
                setpointer(gcf,'SOM topbottom');
                set(d.motionmetaslice,'visible','off');
                dragfinis(d.draggedarrow);
                
            case 'ZnewText'
                Y=U2;
                if(Y==0)
                    newa=arrow(d.axz,'left', [0 Y+0.0001]);
                else
                    newa=arrow(d.axz,'left', [0 Y]);
                end
                set(gcf,'currentaxes',d.axmain);
                ydivisions=(size(d.data,3)-1);
                ydivisions=(d.zlim(2)-d.zlim(1))/ydivisions;
                nYDIV=((Y-d.zlim(1))/ydivisions)+1;
                newYVal=round(nYDIV);
                
                newYVal=d.zlim(1)+(newYVal-1)*ydivisions;
                h=findobj(gcf,'Tag','slice_u3');
                set(h,'string',num2str(newYVal));
                
                new=localslice(d.data, [], [], nYDIV);
                set(new,'alphadata',get(new,'cdata'),'alphadatamapping','scaled');
                setappdata(new,'controlarrow',newa);
                setappdata(newa(2),'arrowslice',new);
                set(newa,'buttondownfcn','sliceomatic Zmove');
                set([new newa],'uicontextmenu',d.uic);
                % Make sure whatever buttonupfcn on the figure is run now to "turn
                % off" whatever was going on before we got our callback on the
                % arrow.
                buf = get(gcf,'windowbuttonupfcn');
                if ~strcmp(buf,'')
                    eval(buf);
                end
                d.draggedarrow=newa(2);
                dragprep(newa(2));
                setpointer(gcf,'SOM topbottom');
                set(d.motionmetaslice,'visible','off');
                dragfinis(d.draggedarrow);
                
                %-----------------------Modification finished by 12th may 2003 srikanth---------------
                
            case 'Xnew'
                if strcmp(get(gcf,'selectiontype'),'normal')
                    pt=get(gcbo,'currentpoint');
                    axis(gcbo);
                    X=pt(1,1);
                    
                    %Modified by srikanth
                    %to get the right slice; TGP July 2005 further modified
                    xdivisions=(size(d.data,2));
                    xdivisions=(d.xlim(2)-d.xlim(1))/xdivisions;
                    nXDIV=((X-d.xlim(1))/xdivisions);
                    newa=arrow(gcbo,'down',[X 0]);
                    set(gcf,'currentaxes',d.axmain);
                    new=localslice(d.data, nXDIV, [], []);
                    
                    setappdata(new,'controlarrow',newa);
                    setappdata(newa(2),'arrowslice',new);
                    set(new,'alphadata',get(new,'cdata'),'alphadatamapping','scaled');
                    set(newa,'buttondownfcn','sliceomatic Xmove');
                    set([new newa],'uicontextmenu',d.uic);
                    % Make sure whatever buttonupfcn on the figure is run now to "turn
                    % off" whatever was going on before we got our callback on the
                    % arrow.
                    % *** Remove:
                    %           ixf_plotdata('set',new,'object_type',IXG_ST_STDVALUES.plot_object_type);
                    buf = get(gcf,'windowbuttonupfcn');
                    if ~strcmp(buf,'')
                        eval(buf);
                    end
                    d.draggedarrow=newa(2);
                    dragprep(newa(2));
                    setpointer(gcf,'SOM leftright');
                    set(d.motionmetaslice,'visible','off');
                end
            case 'Ynew'
                if strcmp(get(gcf,'selectiontype'),'normal')
                    pt=get(gcbo,'currentpoint');
                    Y=pt(1,2);
                    ydivisions=(size(d.data,1));
                    ydivisions=(d.ylim(2)-d.ylim(1))/ydivisions;
                    nYDIV=((Y-d.ylim(1))/ydivisions);
                    newa=arrow(gcbo,'right',[0 Y]);
                    set(gcf,'currentaxes',d.axmain);
                    new=localslice(d.data, [], nYDIV, []);
                    
                    setappdata(new,'controlarrow',newa);
                    setappdata(newa(2),'arrowslice',new);
                    set(new,'alphadata',get(new,'cdata'),'alphadatamapping','scaled');
                    set(newa,'buttondownfcn','sliceomatic Ymove');
                    set([new newa],'uicontextmenu',d.uic);
                    % Make sure whatever buttonupfcn on the figure is run now to "turn
                    % off" whatever was going on before we got our callback on the
                    % arrow.
                    % *** Remove:
                    %                     ixf_plotdata('set',new,'object_type',IXG_ST_STDVALUES.plot_object_type);
                    buf = get(gcf,'windowbuttonupfcn');
                    if ~strcmp(buf,'')
                        eval(buf);
                    end
                    d.draggedarrow=newa(2);
                    dragprep(newa(2));
                    setpointer(gcf,'SOM topbottom');
                    set(d.motionmetaslice,'visible','off');
                end
            case 'Znew'
                if strcmp(get(gcf,'selectiontype'),'normal')
                    pt=get(gcbo,'currentpoint');
                    Y=pt(1,2);
                    newa=arrow(gcbo,'left', [0 Y]);
                    set(gcf,'currentaxes',d.axmain);
                    ydivisions=(size(d.data,3));
                    ydivisions=(d.zlim(2)-d.zlim(1))/ydivisions;
                    nYDIV=((Y-d.zlim(1))/ydivisions);
                    new=localslice(d.data, [], [], nYDIV);
                    set(new,'alphadata',get(new,'cdata'),'alphadatamapping','scaled');
                    % *** Remove:
                    %           ixf_plotdata('set',new,'object_type',IXG_ST_STDVALUES.plot_object_type);
                    setappdata(new,'controlarrow',newa);
                    setappdata(newa(2),'arrowslice',new);
                    set(newa,'buttondownfcn','sliceomatic Zmove');
                    set([new newa],'uicontextmenu',d.uic);
                    % Make sure whatever buttonupfcn on the figure is run now to "turn
                    % off" whatever was going on before we got our callback on the
                    % arrow.
                    buf = get(gcf,'windowbuttonupfcn');
                    if ~strcmp(buf,'')
                        eval(buf);
                    end
                    d.draggedarrow=newa(2);
                    dragprep(newa(2));
                    setpointer(gcf,'SOM topbottom');
                    set(d.motionmetaslice,'visible','off');
                end
            case 'ISO'
                if strcmp(get(gcf,'selectiontype'),'normal')
                    if all(isfield(d,{'reducelims', 'reduce','reducesmooth'}))
                        
                        pt=get(gcbo,'currentpoint');
                        V=pt(1,1);
                        newa=arrow(gcbo,'up',[V 0]);
                        set(gcf,'currentaxes',d.axmain);
                        new=localisosurface(d.reducelims,d.reduce,d.reducesmooth,V);
                        set([newa new],'uicontextmenu',d.uiciso);
                        setappdata(new,'controlarrow',newa);
                        setappdata(new,'reduced',1);
                        setappdata(newa(2),'arrowiso',new);
                        set(newa,'buttondownfcn','sliceomatic ISOmove');
                        % Make sure whatever buttonupfcn on the figure is run now to "turn
                        % off" whatever was going on before we got our callback on the
                        % arrow.
                        buf = get(gcf,'windowbuttonupfcn');
                        if ~strcmp(buf,'')
                            eval(buf);
                        end
                        d.draggedarrow=newa(2);
                        dragprep(newa(2));
                        setpointer(gcf,'SOM leftright');
                    else
                        warndlg('Data for isonormals is missing. Plot the sliceomatic with isonormals turned on to use this feature')
                    end
                end
            case 'Xmove'
                if strcmp(get(gcf,'selectiontype'),'normal')
                    [a s]=getarrowslice;
                    d.draggedarrow=a;
                    dragprep(a);
                end
            case 'Ymove'
                if strcmp(get(gcf,'selectiontype'),'normal')
                    [a s]=getarrowslice;
                    d.draggedarrow=a;
                    dragprep(a);
                end
            case 'Zmove'
                if strcmp(get(gcf,'selectiontype'),'normal')
                    [a s]=getarrowslice;
                    d.draggedarrow=a;
                    dragprep(a);
                end
            case 'ISOmove'
                if strcmp(get(gcf,'selectiontype'),'normal')
                    [a s]=getarrowslice;
                    d.draggedarrow=a;
                    dragprep(a);
                end
            case 'up'
                if strcmp(get(gcf,'selectiontype'),'normal')
                    dragfinis(d.draggedarrow);
                end
            case 'motion'
                % Make sure our cursor is ok
                a=d.draggedarrow;			% The arrow being dragged
                s=getappdata(a,'arrowslice');	% The slice to 'move'
                if isempty(s)
                    s=getappdata(a,'arrowiso');	% or the isosurface
                end
                aa=get(a,'parent');		% arrow's parent axes
                pos=getappdata(a,'arrowcenter');	% the line the arrow points at.
                apos=get(aa,'currentpoint');
                if aa==d.axx | aa==d.axiso
                    % This might be a slice, or an isosurface!
                    if aa==d.axiso
                        if apos(1,1) >= d.clim(1,1) & apos(1,1)<= d.clim(1,2)
                            xdiff=apos(1,1)-pos(1,1);
                            v=get(a,'vertices');
                            v(:,1)=v(:,1)+xdiff;
                            set([a getappdata(a,'arrowedge')],'vertices',v);
                            np=[ apos(1,1) 0 ];
                            new=localisosurface(d.reducelims,d.reduce,d.reducesmooth,...
                                apos(1,1),s);
                            setappdata(new,'reduced',1);
                            movetipforarrow(d.tip, aa, apos(1,1), [ apos(1,1) 6 ], 'bottom','center')
                            setappdata(a,'arrowcenter',np);
                        end
                    else
                        xdivision=(d.xlim(2)-d.xlim(1))/(size(d.data,2));
                        apos(2,1)=((apos(2,1)-d.xlim(1))/xdivision);
                        if apos(2,1) < size(d.data,2) & apos(2,1)>=0
                            xdiff=apos(1,1)-pos(1,1);
                            v=get(a,'vertices');
                            v(:,1)=v(:,1)+xdiff;
                            set([a getappdata(a,'arrowedge')],'vertices',v);
                            np=[ apos(1,1) 0 ];
                            localslice(d.data, apos(2,1), [], [],s);
                            movetipforarrow(d.tip, aa, apos(1,1), [ apos(1,1) .5 ],'top','center');
                            setappdata(a,'arrowcenter',np);
                        end
                    end
                else
                    % We are moving a Y or Z slice
                    ydiff=apos(1,2)-pos(1,2);
                    v=get(a,'vertices');
                    v(:,2)=v(:,2)+ydiff;
                    np=[ 0 apos(1,2) ];
                    if aa==d.axy
                        ydivision=(d.ylim(2)-d.ylim(1))/(size(d.data,1));
                        apos(1,2)=((apos(1,2)-d.ylim(1))/ydivision);
                        if apos(1,2) <= size(d.data,1) & apos(1,2) >=0
                            localslice(d.data, [], apos(1,2), [], s);
                            movetipforarrow(d.tip, aa, apos(2,2), [ 5.5 apos(2,2) ], 'middle','left');
                            set([a getappdata(a,'arrowedge')],'vertices',v);
                            setappdata(a,'arrowcenter',np);
                        end
                    else
                        zdivision=(d.zlim(2)-d.zlim(1))/(size(d.data,3));
                        apos(1,2)=((apos(1,2)-d.zlim(1))/zdivision);
                        if apos(1,2) <= size(d.data,3) & apos(1,2)>=0
                            localslice(d.data, [], [], apos(1,2), s);
                            movetipforarrow(d.tip, aa, apos(2,2), [ .5 apos(2,2) ], 'middle','right');
                            set([a getappdata(a,'arrowedge')],'vertices',v);
                            setappdata(a,'arrowcenter',np);
                        end
                    end
                end
                drawnow;
                %
                % IsoSurface context menu items
                %
            case 'isotogglevisible'
                [a s]=getarrowslice;
                if propcheck(s,'visible','on')
                    set(s,'visible','off');
                else
                    set(s,'visible','on');
                end
                %Added by srikanth to delete all isosurfaces
            case 'isodeleteall'
                isosurfs=allIsos;
                for i=1:size(isosurfs)
                    a=getappdata(isosurfs(i),'controlarrow');
                    if numel(a)==1
                        delete(getappdata(a,'arrowedge'));
                    end
                    cap=getappdata(isosurfs(i),'isosurfacecap');
                    if ~isempty(cap)
                        delete(cap);
                    end
                    delete(isosurfs(i));
                    delete(a);
                end
                
                
            case 'isodelete'
                [a s]=getarrowslice;
                if numel(a)==1
                    delete(getappdata(a,'arrowedge'));
                end
                cap=getappdata(s,'isosurfacecap');%modified so that isocap can be deleted
                if ~isempty(cap)
                    delete(cap);
                end
                delete(s);
                delete(a);
            case 'isoflatlight'
                [a s]=getarrowslice;
                set(s,'facelighting','flat');
            case 'isosmoothlight'
                [a s]=getarrowslice;
                set(s,'facelighting','phong');
            case 'isocolor'
                [a s]=getarrowslice;
                c=uisetcolor(get(s,'facecolor'));
                set(s,'facecolor',c);
            case 'isoalpha'
                [a s]=getarrowslice;
                if nargin ~= 2
                    error('Not enough arguments to sliceomatic.');
                end
                set(s,'facealpha',eval(U2));
            case 'isocaps'
                [a s]=getarrowslice;
                cap=getappdata(s,'isosurfacecap');
                if isempty(cap)
                    new=localisocaps(s);
                    set(new,'uicontextmenu',d.uiciso);
                else
                    delete(cap);
                    setappdata(s,'isosurfacecap',[]);
                end
                %
                % Now for slice context menu items
                %
            case 'togglevisible'
                [a s]=getarrowslice;
                switch get(s,'visible')
                    case 'on'
                        set(s,'visible','off');
                        pushset(a,'facealpha',.2);
                    case 'off'
                        set(s,'visible','on');
                        popset(a,'facealpha');
                end
            case 'setfaceted'
                [a s]=getarrowslice;
                set(s,'edgec','k','facec','flat');
                if ischar(get(s,'facea')) & strcmp(get(s,'facea'),'texturemap')
                    set(s,'facea','flat');
                end
                textureizeslice(s,'off');
            case 'setflat'
                [a s]=getarrowslice;
                set(s,'edgec','n','facec','flat');
                if ischar(get(s,'facea')) & strcmp(get(s,'facea'),'texturemap')
                    set(s,'facea','flat');
                end
                textureizeslice(s,'off');
            case 'setinterp'
                [a s]=getarrowslice;
                set(s,'edgec','n','facec','interp');
                if ischar(get(s,'facea')) & strcmp(get(s,'facea'),'texturemap')
                    set(s,'facea','interp');
                end
                textureizeslice(s,'off');
            case 'settexture'
                [a s]=getarrowslice;
                set(s,'facecolor','texture','edgec','none');
                if ischar(get(s,'facea'))
                    set(s,'facealpha','texturemap');
                end
                textureizeslice(s,'on');
            case 'setnone'
                [a s]=getarrowslice;
                set(s,'facecolor','none','edgec','none');
                textureizeslice(s,'off');
            case 'setalphanone'
                [a s]=getarrowslice;
                set(s,'facealpha',1);
            case 'setalphapoint5'
                [a s]=getarrowslice;
                set(s,'facealpha',.5);
            case 'setalphaflat'
                [a s]=getarrowslice;
                set(s,'facealpha','flat');
                if ischar(get(s,'facec')) & strcmp(get(s,'facec'),'texturemap')
                    set(s,'facecolor','flat');
                    textureizeslice(s,'off');
                end
            case 'setalphainterp'
                [a s]=getarrowslice;
                set(s,'facealpha','interp');
                if ischar(get(s,'facec')) & strcmp(get(s,'facec'),'texturemap')
                    set(s,'facecolor','interp');
                    textureizeslice(s,'off');
                end
            case 'setalphatexture'
                [a s]=getarrowslice;
                set(s,'facealpha','texturemap');
                if ischar(get(s,'facec'))
                    set(s,'facecolor','texturemap');
                    textureizeslice(s,'on');
                end
            case 'slicecontour'
                [a s]=getarrowslice;
                localcontour(s, getappdata(s,'contour'));
            case 'deleteslice'
                [a s]=getarrowslice;
                if prod(size(a))==1
                    delete(getappdata(a,'arrowedge'));
                end
                if ~isempty(getappdata(s,'contour'))
                    delete(getappdata(s,'contour'));
                end
                delete(s);
                delete(a);
            case 'deleteslicecontour'
                [a s]=getarrowslice;
                if ~isempty(getappdata(s,'contour'))
                    delete(getappdata(s,'contour'));
                end
                setappdata(s,'contour',[]);
            case 'slicecontourflat'
                [a s]=getarrowslice;
                c = getappdata(s,'contour');
                if ~isempty(c)
                    set(c,'edgecolor','flat');
                end
            case 'slicecontourinterp'
                [a s]=getarrowslice;
                c = getappdata(s,'contour');
                if ~isempty(c)
                    set(c,'edgecolor','interp');
                end
            case 'slicecontourblack'
                [a s]=getarrowslice;
                c = getappdata(s,'contour');
                if ~isempty(c)
                    set(c,'edgecolor','black');
                end
            case 'slicecontourwhite'
                [a s]=getarrowslice;
                c = getappdata(s,'contour');
                if ~isempty(c)
                    set(c,'edgecolor','white');
                end
            case 'slicecontourcolor'
                [a s]=getarrowslice;
                c = getappdata(s,'contour');
                if ~isempty(c)
                    inputcolor = get(c,'edgecolor');
                    if isa(inputcolor,'char')
                        inputcolor=[ 1 1 1 ];
                    end
                    set(c,'edgecolor',uisetcolor(inputcolor));
                end
            case 'slicecontourlinewidth'
                [a s]=getarrowslice;
                c = getappdata(s,'contour');
                if ~isempty(c)
                    if isa(U2,'char')
                        set(c,'linewidth',str2num(U2));
                    else
                        set(c,'linewidth',U2);
                    end
                end
                %
                % Menu All Slices
                %
            case 'allfacet'
                s=allSlices;
                set(s,'facec','flat','edgec','k');
                textureizeslice(s,'off');
            case 'allflat'
                s=allSlices;
                set(s,'facec','flat','edgec','none');
                textureizeslice(s,'off');
            case 'allinterp'
                s=allSlices;
                set(s,'facec','interp','edgec','none');
                textureizeslice(s,'off');
            case 'alltex'
                s=allSlices;
                set(s,'facec','texturemap','edgec','none');
                textureizeslice(s,'on');
            case 'allnone'
                s=allSlices;
                set(s,'facec','none','edgec','none');
                textureizeslice(s,'off');
            case 'alltnone'
                s=allSlices;
                set(s,'facea',1);
                textureizeslice(s,'off');
            case 'alltp5'
                s=allSlices;
                set(s,'facea',.5);
                textureizeslice(s,'off');
            case 'alltflat'
                s=allSlices;
                set(s,'facea','flat');
                textureizeslice(s,'off');
            case 'alltinterp'
                s=allSlices;
                set(s,'facea','interp');
                textureizeslice(s,'off');
            case 'allttex'
                s=allSlices;
                set(s,'facea','texturemap');
                textureizeslice(s,'on');
                %
                % Menu Defaults callbacks
                %
            case	'defaultfaceted'
                d.defcolor='faceted';
            case	'defaultflat'
                d.defcolor='flat';
            case	'defaultinterp'
                d.defcolor='interp';
            case	'defaulttexture'
                d.defcolor='texture';
                if strcmp(d.defalpha,'flat') | strcmp(d.defalpha,'interp')
                    d.defalpha='texture';
                end
            case	'defaultinterp'
                d.defcolor='none';
            case	'defaulttransnone'
                d.defalpha='none';
            case	'defaulttransflat'
                d.defalpha='flat';
            case	'defaulttransinterp'
                d.defalpha='interp';
            case	'defaulttranstexture'
                d.defalpha='texture';
                d.defcolor='texture';
            case      'defaultlightflat'
                d.deflight='flat';
            case      'defaultlightsmooth'
                d.deflight='smooth';
            case 'defaultcontourflat'
                d.defcontourcolor='flat';
            case 'defaultcontourinterp'
                d.defcontourcolor='interp';
            case 'defaultcontourblack'
                d.defcontourcolor='black';
            case 'defaultcontourwhite'
                d.defcontourcolor='white';
            case 'defaultcontourlinewidth'
                if isa(U2,'char')
                    d.defcontourlinewidth=str2num(U2);
                else
                    d.defcontourlinewidth=U2;
                end
                %
                % Camera toolbar Toggling
                %
            case 'cameratoolbar'
                cameratoolbar('Toggle');
                %
                % Controler Preferences
                %
            case 'controlalpha'
                val=str2num(U2);
                iso=findobj(d.axiso,'type','image');
                if val == 0
                    set([d.pxx d.pxy d.pxz iso],'visible','off');
                else
                    set([d.pxx d.pxy d.pxz iso],'visible','on');
                    set([d.pxx d.pxy d.pxz] , 'facealpha',val);
                    set(iso,'alphadata',val);
                end
            case 'controllabels'
                l = get(d.axx,'xticklabel');
                if isempty(l)
                    set([d.axx d.axiso],'xticklabelmode','auto');
                    set([d.axy d.axz],'yticklabelmode','auto');
                else
                    set([d.axx d.axiso],'xticklabel',[]);
                    set([d.axy d.axz],'yticklabel',[]);
                end
            case 'controlvisible'
                objs=findobj([d.axiso d.axx d.axy d.axz]);
                if strcmp(get(d.axx,'visible'),'on')
                    set(objs,'visible','off');
                    set(d.axmain,'pos',[.1 .1 .9 .8]);
                else
                    set(objs,'visible','on');
                    set(d.axmain,'pos',[.2  .2 .6 .6]);
                end
                %
                % UICONTROL callbacks
                %
            case 'colormap'
                str=get(gcbo,'string');
                val=str{get(gcbo,'value')};
                size(val);
                if strcmp(val,'custom')
                    cmapeditor
                else
                    colormap(val);
                end
            case 'alphamap'
                str=get(gcbo,'string');
                alphamap(str{get(gcbo,'value')});
                %
                % Commands
                %
            case 'copy'
                copyobj(gca,figure);set(gca,'pos',[.1 .1 .9 .8]);
            case 'print'
                newf=figure('visible','off','renderer',get(gcf,'renderer'));
                copyobj(d.axmain,newf);
                set(gca,'pos',[.1 .1 .9 .8])
                printdlg(newf);
                close(newf);
            otherwise
                error('Bad slice-o-matic command.');
        end
    catch
        disp(get(0,'errormessage'));
    end
    setappdata(gcf,'sliceomatic',d);
end

%-------------------------------------------------------------------------------------------------
% Fix following Alex Buts, 22/12/2012:
% Fixes problem on dual monitor systems. Need checks about negative side effects on other systems.
% Will reset just before exiting this function
set(0, 'DefaultFigureRendererMode', mode);
set(0,'DefaultFigureRenderer',rend );
%-------------------------------------------------------------------------------------------------


function dragprep(arrowtodrag)
arrows=findall(gcf,'tag','sliceomaticarrow');

pushset(arrows,'facecolor','r');
pushset(arrows,'facealpha',.2);

pushset(arrowtodrag,'facecolor','g');
pushset(arrowtodrag,'facealpha',.7);

slices=allSlices;

for i=1:length(slices)
    fa=get(slices(i),'facea');
    if isa(fa,'double') & fa>.3
        pushset(slices(i),'facealpha',.3);
        pushset(slices(i),'edgecolor','n');
    else
        pushset(slices(i),'facealpha',fa);
        pushset(slices(i),'edgecolor',get(slices(i),'edgec'));
    end
end

isosurfs=allIsos;

for i=1:length(isosurfs)
    fa=get(isosurfs(i),'facea');
    if isa(fa,'double') & fa>.3
        pushset(isosurfs(i),'facealpha',.3);
        pushset(isosurfs(i),'edgecolor','n');
    else
        pushset(isosurfs(i),'facealpha',fa);
        pushset(isosurfs(i),'edgecolor',get(isosurfs(i),'edgec'));
    end
    cap=getappdata(isosurfs(i),'isosurfacecap');
    if ~isempty(cap)
        pushset(cap,'visible','off');
    end
end

ss=getappdata(arrowtodrag,'arrowslice');

if isempty(ss)
    ss=getappdata(arrowtodrag,'arrowiso');
end

popset(ss,'facealpha');
popset(ss,'edgecolor');

pushset(gcf,'windowbuttonupfcn','sliceomatic up');
pushset(gcf,'windowbuttonmotionfcn','sliceomatic motion');

d=getappdata(gcf,'sliceomatic');

% Doing this makes the tip invisible when visible is on.
set(d.tip,'string','');
pushset(d.tip,'visible','on');

function dragfinis(arrowtodrag)
arrows=findall(gcf,'tag','sliceomaticarrow');

popset(arrowtodrag,'facecolor');
popset(arrowtodrag,'facealpha');

popset(arrows,'facecolor');
popset(arrows,'facealpha');

ss=getappdata(arrowtodrag,'arrowslice');
if isempty(ss)
    ss=getappdata(arrowtodrag,'arrowiso');
end

% These pushes are junk which will be undone when all slices or
% isosurfs are reset below.
pushset(ss,'facealpha',1);
pushset(ss,'edgecolor','k');

slices=allSlices;

if ~isempty(slices)
    popset(slices,'facealpha');
    popset(slices,'edgecolor');
end

isosurfs=allIsos;

if ~isempty(isosurfs)
    popset(isosurfs,'facealpha');
    popset(isosurfs,'edgecolor');
end

d=getappdata(gcf,'sliceomatic');

for i=1:length(isosurfs)
    cap=getappdata(isosurfs(i),'isosurfacecap');
    if ~isempty(cap)
        popset(cap,'visible');
        localisocaps(isosurfs(i),cap);
    end
end

popset(gcf,'windowbuttonupfcn');
popset(gcf,'windowbuttonmotionfcn');

popset(d.tip,'visible');

% Make sure whatever buttonupfcn on the figure is run now to "turn
% off" whatever was going on before we got our callback on the
% arrow.

buf = get(gcf,'windowbuttonupfcn');
if ~strcmp(buf,'')
    eval(buf);
end

function movetipforarrow(tip, ax, value, position, va, ha)
% Setup the current data tip for a slice arrow, and show it's
% control value
set(tip,'parent',ax, ...
    'string',sprintf('Value: %1.3f',value),...
    ... 'string','o', ...
    'units','data', ...
    'position', position, ...
    'verticalalignment', va,...
    'horizontalalignment', ha);
set(tip,'units','pixels');
% Put it onto d.axisiso so that
% it always appears on top.
%set(t,'parent',d.axiso);

function p=arrow(parent,dir,pos)

%   21012    21012      12345     12345
% 5  *-*   5   *     2   *     2   *
% 4  | |   4  / \    1 *-*\    1  /*-*
% 3 ** **  3 ** **   0 |   *   0 *   |
% 2  \ /   2  | |   -1 *-*/   -1  \*-*
% 1   *    1  *-*   -2   *    -2   *

switch dir
    case 'down'
        pts=[ 0 1; -2 3; -1 3; -1 5; 1 5; 1 3; 2 3 ];
        mp = 'SOM leftright';
    case 'up'
        pts=[ 0 5; 2 3; 1 3; 1 1; -1 1; -1 3; -2 3; ];
        mp = 'SOM leftright';
    case 'right'
        pts=[ 5 0; 3 -2; 3 -1; 1 -1; 1 1; 3 1; 3 2 ];
        mp = 'SOM topbottom';
    case 'left'
        pts=[ 1 0; 3 2; 3 1; 5 1; 5 -1; 3 -1; 3 -2 ];
        mp = 'SOM topbottom';
end

f=[1 2 7; 3 4 5; 3 5 6 ];

% Modify the arrows to look good no matter what
% the data aspect ratio may be.
if pos(1)
    lim=get(parent,'xlim');
    fivep=abs(lim(1)-lim(2))/15/5;
    pts(:,1)=pts(:,1)*fivep+pos(1);
elseif pos(2)
    lim=get(parent,'ylim');
    fivep=abs(lim(1)-lim(2))/15/5;
    pts(:,2)=pts(:,2)*fivep+pos(2);
end

% Create the patches, and add app data to them to remember what
% They are associated with.
p(1)=patch('vertices',pts,'faces',1:size(pts,1),'facec','n','edgec','k',...
    'linewidth',2,'hittest','off',...
    'parent',parent);
p(2)=patch('vertices',pts,'faces',f,'facec','g','facea',.5,'edgec','n',...
    'parent',parent,'tag','sliceomaticarrow');
setappdata(p(2),'arrowcenter',pos);
setappdata(p(2),'arrowedge',p(1));
setappdata(p(2),'motionpointer',mp);


function p=localisocaps(isosurface,isocap)
% Isocap management
% Get relevant info from the isosurface.
d=getappdata(gcf,'sliceomatic');
if nargin<2 | ~strcmp(get(isocap,'visible'),'off')
    data=getappdata(isosurface,'isosurfacedata');
    caps=isocaps(d.Xv,d.Yv,d.Zv,d.data,getappdata(isosurface,'isosurfacevalue'),'below');
end

if nargin==2
    if ~strcmp(get(isocap,'visible'),'off')
        set(isocap,caps);
    end
    p=isocap;
else
    p=patch(caps,'edgecolor','none','facecolor','interp',...
        'facelighting','none',...
        'tag','sliceomaticisocap');
    
    setappdata(p,'isosurface',isosurface);
    setappdata(isosurface,'isosurfacecap',p);
    
    d=getappdata(gcf,'sliceomatic');
    
    %     switch d.defcolor
    %      case 'faceted'
    %       set(p,'facec','flat','edgec','black');
    %      case 'flat'
    %       set(p,'facec','flat','edgec','none');
    %      case 'interp'
    %       set(p,'facec','interp','edgec','none');
    %      case 'texture'
    %       set(p,'facec','flat','edgec','none');
    %      case 'none'
    %       set(p,'facec','none','edgec','none');
    %     end
    
    switch d.defalpha
        case 'none'
            set(p,'facea',1);
        case 'flat'
            set(p,'facea','flat');
        case 'interp'
            set(p,'facea','interp');
        case 'texture'
            set(p,'facea','flat');
    end
end


function p=localisosurface(volume, data, datanormals, value, oldiso)
% Isosurface management
pushset(gcf, 'pointer','watch');
d=getappdata(gcf,'sliceomatic');
%modified by srikanth on 9th may 2003
if ~isempty(volume)
    fv = isosurface(volume{:},data, value);
else
    fv= isosurface(d.reducelims{:},data,value);
end
clim=get(gca,'clim');
cmap=get(gcf,'colormap');
clen=clim(2)-clim(1);
idx=floor((value-clim(1))*length(cmap)/clen);
if idx==0
    idx=1;
end
if nargin==5
    set(oldiso,fv,'facecolor',cmap(idx,:));
    p=oldiso;
    cap=getappdata(p,'isosurfacecap');
    if ~isempty(cap)
        localisocaps(p,cap);
    end
else
    p=patch(fv,'edgecolor','none','facecolor',cmap(idx,:),...
        'tag', 'sliceomaticisosurface');
    d=getappdata(gcf,'sliceomatic');
    switch d.deflight
        case 'flat'
            set(p,'facelighting','flat');
        case 'smooth'
            set(p,'facelighting','phong');
    end
    setappdata(p,'isosurfacecap',[]);
end

setappdata(p,'isosurfacevalue',value);
setappdata(p,'isosurfacedata',data);

reducepatch(p,10000);
isonormals(volume{:},datanormals,p);
popset(gcf,'pointer');

%Modified by srikanth
%This has to be modified so that the meshgrid is according to data ok.
function s=localslice(data, X, Y, Z, oldslice)
% Slice Management.  Uses specialized slicomatic slices, not slices
% created with the SLICE command.
% Further modified TGP July 2005
s=[];
d=getappdata(gcf,'sliceomatic');

ds=size(data);
xdivision=(d.xlim(2)-d.xlim(1))/(size(d.data,2)-1);    % TGP notes that these are WRONG - still seems not to alter the plot tho'
ydivision=(d.ylim(2)-d.ylim(1))/(size(d.data,1)-1);
zdivision=(d.zlim(2)-d.zlim(1))/(size(d.data,3)-1);
deltax = (d.xlim(2)-d.xlim(1))/(size(d.data,2));  % added by TGP July 2005
deltay = (d.ylim(2)-d.ylim(1))/(size(d.data,1));
deltaz = (d.zlim(2)-d.zlim(1))/(size(d.data,3));
if ~isempty(X)
    xi=max(1,min(ceil(X),size(d.data,2)));        % Before TGP: was xi = round(X); similiarly for y and z axes
    newX=d.xlim(1)+X*deltax;
    if newX >= d.xlim(1) & newX <= d.xlim(2)
        cdata=reshape(data(:,xi,:),ds(1),ds(3));
        [xdata ydata zdata]=meshgrid(newX,d.ylim(1):ydivision:d.ylim(2),d.zlim(1):zdivision:d.zlim(2));
        st = 'X';
    else
        return
    end
elseif ~isempty(Y)
    yi=max(1,min(ceil(Y),size(d.data,1)));
    newY=d.ylim(1)+Y*deltay;
    if  newY >= d.ylim(1) & newY <= d.ylim(2)
        cdata=reshape(data(yi,:,:),ds(2),ds(3));
        [xdata ydata zdata]=meshgrid(d.xlim(1):xdivision:d.xlim(2),newY,d.zlim(1):zdivision:d.zlim(2));
        st = 'Y';
    else
        return
    end
elseif ~isempty(Z)
    zi=max(1,min(ceil(Z),size(d.data,3)));
    newZ=d.zlim(1)+Z*deltaz;
    if newZ >= d.zlim(1) & newZ <= d.zlim(2)
        cdata=reshape(data(:,:,zi),ds(1),ds(2));
        [xdata ydata zdata]=meshgrid(d.xlim(1):xdivision:d.xlim(2),d.ylim(1):ydivision:d.ylim(2),newZ);
        st = 'Z';
    else
        return
    end
else
    error('Nothing was passed into LOCALSLICE.');
end

cdata=squeeze(cdata);
xdata=squeeze(xdata);
ydata=squeeze(ydata);
zdata=squeeze(zdata);

if nargin == 5
    % Recycle the old slice
    set(oldslice,'cdata',cdata,'alphadata',cdata, 'xdata',xdata, ...
        'ydata',ydata, 'zdata',zdata);
    s=oldslice;
    %delete(news);
    if propcheck(s,'facec','texturemap')
        textureizeslice(s,'on');
    end
    
else
    % setup the alphadata
    news=surface('cdata',cdata,'alphadata',cdata, 'xdata',xdata, ...
        'ydata',ydata, 'zdata',zdata);
    set(news,'alphadata',cdata,'alphadatamapping','scaled','tag','sliceomaticslice',...
        'facelighting','none',...
        'uicontextmenu',d.uic);
    s=news;
    switch d.defcolor
        case 'faceted'
            set(s,'facec','flat','edgec','k');
        case 'flat'
            set(s,'facec','flat','edgec','n');
        case 'interp'
            set(s,'facec','interp','edgec','n');
        case 'texture'
            set(s,'facec','texture','edgec','n');
    end
    switch d.defalpha
        case 'none'
            set(s,'facea',1);
        case 'flat'
            set(s,'facea','flat');
        case 'interp'
            set(s,'facea','interp');
        case 'texture'
            set(s,'facea','texture');
    end
    
    setappdata(s,'slicetype',st);
    
    if strcmp(d.defcolor,'texture')
        textureizeslice(s,'on');
    end
end

contour = getappdata(s,'contour');
if ~isempty(contour)
    localcontour(s, contour);
end


function textureizeslice(slice,onoff)
% Convert a regular slice into a texture map slice, or a texture
% slice into a regular slice.

for k=1:prod(size(slice))
    
    d=getappdata(slice(k),'textureoptimizeations');
    
    switch onoff
        case 'on'
            d.xdata=get(slice(k),'xdata');
            d.ydata=get(slice(k),'ydata');
            d.zdata=get(slice(k),'zdata');
            setappdata(slice(k),'textureoptimizeations',d);
            if max(size(d.xdata)==1)
                nx=[d.xdata(1) d.xdata(end)];
            else
                nx=[d.xdata(1,1)   d.xdata(1,end);
                    d.xdata(end,1) d.xdata(end,end)];
            end
            if max(size(d.ydata)==1)
                ny=[d.ydata(1) d.ydata(end)];
            else
                ny=[d.ydata(1,1)   d.ydata(1,end);
                    d.ydata(end,1) d.ydata(end,end)];
            end
            if max(size(d.zdata)==1)
                nz=[d.zdata(1) d.zdata(end)];
            else
                nz=[d.zdata(1,1)   d.zdata(1,end);
                    d.zdata(end,1) d.zdata(end,end)];
            end
            set(slice(k),'xdata',nx, 'ydata', ny, 'zdata', nz,...
                'facec','texturemap');
            if ischar(get(slice(k),'facea'))
                set(slice(k),'facea','texturemap');
            end
            if ischar(get(slice(k),'facec'))
                set(slice(k),'facec','texturemap');
            end
        case 'off'
            if ~isempty(d)
                set(slice(k),'xdata',d.xdata,'ydata',d.ydata,'zdata',d.zdata);
                setappdata(slice(k),'textureoptimizeations',[]);
            end
            if ischar(get(slice(k),'facea')) & strcmp(get(slice(k),'facea'),'texturemap')
                set(slice(k),'facea','flat');
            end
            if ischar(get(slice(k),'facec')) & strcmp(get(slice(k),'facec'),'texturemap')
                set(slice(k),'facec','flat');
            end
    end
end

function localcontour(slice,oldcontour)
% Create a contour on SLICE
% When OLDCONTROUR, recycle that contour patch.
% This does not use the CONTOURSLICE command, but instead uses a
% specialized slice created for sliceomantic.
d=getappdata(gcf,'sliceomatic');

cdata = get(slice,'cdata');
st = getappdata(slice,'slicetype');

% Calculate the new contour for CDATA's values.
c = contourc(cdata);

newvertices = [];
newfaces = {};
longest = 1;
cdata = [];

limit = size(c,2);
i = 1;
h = [];
color_h = [];
while(i < limit)
    z_level = c(1,i);
    npoints = c(2,i);
    nexti = i+npoints+1;
    
    xdata = c(1,i+1:i+npoints);
    ydata = c(2,i+1:i+npoints);
    
    switch st
        case 'X'
            xv = get(slice,'xdata');
            lzdata = xv(1,1) + 0*xdata;
            vertices = [[lzdata].', [ydata].', [xdata].'];
        case 'Y'
            yv = get(slice,'ydata');
            lzdata = yv(1,1) + 0*xdata;
            vertices = [[ydata].', [lzdata].', [xdata].'];
        case 'Z'
            zv = get(slice,'zdata');
            lzdata = zv(1,1) + 0*xdata;
            vertices = [[xdata].', [ydata].', [lzdata].'];
    end
    
    faces = 1:length(vertices);
    faces = faces + size(newvertices,1);
    
    longest=max(longest,size(faces,2));
    
    newvertices = [ newvertices ; vertices ];
    newfaces{end+1} = faces;
    
    tcdata =  (z_level + 0*xdata).';
    
    cdata = [ cdata; tcdata ]; % need to be same size as faces
    
    i = nexti;
end

% Fix up FACES, which is a cell array.
faces = [];
for i = 1:size(newfaces,2)
    faces = [ faces;
        newfaces{i} ones(1,longest-size(newfaces{i},2))*nan nan ];
    % Nans don't work in patches in OpenGL with trailing NaNs, but
    % if I fake it out, edges with breaks in them don't work.
    % Bummer!  I tried filling in with the last data point, but
    % then unbroken segmets would fill in again.
end

if isempty(oldcontour)
    oldcontour = patch('facecolor','none', 'edgecolor',d.defcontourcolor,...
        'linewidth',d.defcontourlinewidth);
    setappdata(slice,'contour',oldcontour);
end

set(oldcontour,'vertices',newvertices,...
    'faces',faces,...
    'facevertexcdata',cdata);

function ss=allSlices
ss=findobj(gcf,'type','surface','tag','sliceomaticslice');

function ss=allIsos
ss=findobj(gcf,'type','patch','tag','sliceomaticisosurface');

function ss=allCaps
ss=findobj(gcf,'type','patch','tag','sliceomaticisocap');

function working(onoff)

ax=getappdata(gcf,'workingaxis');

if isempty(ax)
    ax=axes('units','norm','pos',[.3 .4 .4 .2],...
        'box','on','ytick',[],'xtick',[],...
        'xlim',[-1 1],'ylim',[-1 1],...
        'color','none','handlevis','off');
    text('parent',ax,'string','Working...','fontsize',64,...
        'pos',[0 0], ...
        'horizontalalignment','center',...
        'verticalalignment','middle',...
        'erasemode','xor');
    setappdata(gcf,'workingaxis',ax);
end

disp(['Working...' onoff]);
set([ax get(ax,'children')],'vis',onoff);
