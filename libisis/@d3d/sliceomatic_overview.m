function sliceomatic_overview(win,varargin)
%
% sliceomatic_overview(win)
% OR
% sliceomatic_overview(win,axis)
% 
% where win is a 3d object (sqw or d3d)
%       axis is an integer in the range 1 to 3, to specify which axis we
%       want to view along
%
% Do a sliceomatic plot, but set the axes so that we look straight down the
% 3rd (vertical) axis, so that when the slider is moved we get a series of
% what appear to be 2d slices.
%
% RAE 25/3/2010
%

%This is quite simple really - we just have to run sliceomatic and then set
%the camera position appropriately.

if isa(win,'d3d')
    nopix=true;
elseif isa(win,'sqw') && dimensions(win)==3
    nopix=false;
else
    error('Sliceomatic only valid for 3d Horace objects');
end

if ~(nargin==1 || nargin==2)
    error('Check the number of input arguments');
end

if nargin==2
    axis=varargin{1};
else
    axis=3;
end
    
   
if nopix
    plot(win);
    if axis==1
        ycen=median(win.p{win.dax(2)});
        zcen=median(win.p{win.dax(3)});
        xmax=max(win.p{win.dax(1)});
        %
        %Camera pos vector:
        camposvec=[2.*xmax,ycen,zcen];
    elseif axis==2
        xcen=median(win.p{win.dax(1)});
        zcen=median(win.p{win.dax(3)});
        ymax=max(win.p{win.dax(2)});
        %
        %Camera pos vector:
        camposvec=[xcen,2.*ymax,zcen];
    elseif axis==3
        xcen=median(win.p{win.dax(1)});
        ycen=median(win.p{win.dax(2)});
        zmax=max(win.p{win.dax(3)});
        %
        %Camera pos vector:
        camposvec=[xcen,ycen,2.*zmax];
    else
        error('Axis argument must be an integer in the range 1 to 3');
    end
    %Set the camera position
    set(gca,'CameraPosition',camposvec);
else
    if axis==1
            ycen=median(win.data.p{win.data.dax(2)});
            zcen=median(win.data.p{win.data.dax(3)});
            xmax=max(win.data.p{win.data.dax(1)});
            %
            %Camera pos vector:
            camposvec=[2.*xmax,ycen,zcen];
    elseif axis==2
            xcen=median(win.data.p{win.data.dax(1)});
            zcen=median(win.data.p{win.data.dax(3)});
            ymax=max(win.data.p{win.data.dax(2)});
            %
            %Camera pos vector:
            camposvec=[xcen,2.*ymax,zcen];
    elseif axis==3
            xcen=median(win.data.p{win.data.dax(1)});
            ycen=median(win.data.p{win.data.dax(2)});
            zmax=max(win.data.p{win.data.dax(3)});
            %
            %Camera pos vector:
            camposvec=[xcen,ycen,2.*zmax];
    else
            error('Axis argument must be an integer in the range 1 to 3');
    end
    plot(win);
    %
    %Set the camera position
    set(gca,'CameraPosition',camposvec);
end