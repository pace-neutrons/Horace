function [figureHandle, axesHandle, plotHandle] = sliceomatic_overview(w,varargin)
% Plots 3D sqw object using sliceomatic with view straight down one of the axes
%
%   >> sliceomatic_overview (w)         % down third (vertical) axis
%   >> sliceomatic_overview (w, axis)   % down axis of choice (axis=1,2 or 3)
% 
%   >> sliceomatic_overview (w,... 'isonormals', true) % to enable isonormals
%
%   >> sliceomatic_overview (w,...,'-noaspect')  % Do not change aspect ratio
%                                       % according to data axes unit lengths
%
% To get handles to the graphics figure:
%   >> [figureHandle_, axesHandle_, plotHandle_] = sliceomatic(w,...)
%
% Do a sliceomatic plot, but set the axes so that we look straight down the
% chosen axis, so that when the slider is moved we get a series of
% what appear to be 2d slices.
%
%
% NOTES:
%
% - Ensure that the slice colour plotting is in 'texture' mode -
%      On the 'AllSlices' menu click 'Colour Texture'. No indication will
%      be made on this menu to show that it has been selected, but you can
%      see the result if you right-click on an arrow indicating a slice on
%      the graphics window.
%
% - To set the default for future Sliceomatic sessions -
%      On the 'Object_Defaults' menu select 'Slice Colour Texture'

% RAE 25/3/2010

%This is quite simple really - we just have to run sliceomatic and then set
%the camera position appropriately.


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
    ycen=median(w.p{w.dax(2)});
    zcen=median(w.p{w.dax(3)});
    xmax=max(w.p{w.dax(1)});
    camposvec=[2.*xmax,ycen,zcen];  % Camera position vector
elseif axis==2
    xcen=median(w.p{w.dax(1)});
    zcen=median(w.p{w.dax(3)});
    ymax=max(w.p{w.dax(2)});
    camposvec=[xcen,2.*ymax,zcen];  % Camera position vector
elseif axis==3
    xcen=median(w.p{w.dax(1)});
    ycen=median(w.p{w.dax(2)});
    zmax=max(w.p{w.dax(3)});
    camposvec=[xcen,ycen,2.*zmax];  % Camera position vector
else
    error('HORACE:d3d:invalid_argument', ...
        'Axis argument must be an integer in the range 1 to 3');
end

[figureHandle_, axesHandle_, plotHandle_] = sliceomatic(IX_dataset_3d(w),varargin{arg_start:end});

% Set the camera position
set(gca,'CameraPosition',camposvec);

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
