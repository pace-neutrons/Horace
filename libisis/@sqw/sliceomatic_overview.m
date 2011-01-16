function [figureHandle, axesHandle, plotHandle] = sliceomatic_overview(win,varargin)
% Sliceomatic plot with view straight down one of the axes
%
%   >> sliceomatic_overview(win)        % down third (vertical) axis
%   >> sliceomatic_overview(win,axis)   % down axis of choice (axis=1,2 or 3)
% 
%   win     3D sqw object
%   axis    integer in the range 1 to 3, to specify which axis to view along
%
% Do a sliceomatic plot, but set the axes so that we look straight down the
% 3rd (vertical) axis, so that when the slider is moved we get a series of
% what appear to be 2d slices.
%
% To get handles to the graphics figure:
%   >> [figureHandle_, axesHandle_, plotHandle_] = sliceomatic(win)

% RAE 25/3/2010

%This is quite simple really - we just have to run sliceomatic and then set
%the camera position appropriately.

if numel(win)~=1
    error('sliceomatic only works for a single 3D dataset')
end
if dimensions(win)~=3
    error('sliceomatic only works for 3D datasets');
end

% Check arguments for axis index (must make it pass on all extra arguments to sliceomatic)
if numel(varargin)>=1 && isscalar(varargin{1}) && isnumeric(varargin{1})
    axis=varargin{1};
    arg_start=2;    % index of start of remaining arguments
else
    axis=3;
    arg_start=1;
end

% Get camera position vector:
if axis==1
    ycen=median(win.data.p{win.data.dax(2)});
    zcen=median(win.data.p{win.data.dax(3)});
    xmax=max(win.data.p{win.data.dax(1)});
    camposvec=[2.*xmax,ycen,zcen];  % Camera position vector
elseif axis==2
    xcen=median(win.data.p{win.data.dax(1)});
    zcen=median(win.data.p{win.data.dax(3)});
    ymax=max(win.data.p{win.data.dax(2)});
    camposvec=[xcen,2.*ymax,zcen];  % Camera position vector
elseif axis==3
    xcen=median(win.data.p{win.data.dax(1)});
    ycen=median(win.data.p{win.data.dax(2)});
    zmax=max(win.data.p{win.data.dax(3)});
    camposvec=[xcen,ycen,2.*zmax];  % Camera position vector
else
    error('Axis argument must be an integer in the range 1 to 3');
end
[figureHandle_, axesHandle_, plotHandle_] = sliceomatic(win);

% Set the camera position
set(gca,'CameraPosition',camposvec);

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
