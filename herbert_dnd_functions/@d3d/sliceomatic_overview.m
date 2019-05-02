function [figureHandle, axesHandle, plotHandle] = sliceomatic_overview(w,varargin)
% Plots d3d object using sliceomatic with view straight down one of the axes
%
%   >> sliceomatic_overview(w)        % down third (vertical) axis
%   >> sliceomatic_overview(w,axis)   % down axis of choice (axis=1,2 or 3)
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
% 3rd (vertical) axis, so that when the slider is moved we get a series of
% what appear to be 2d slices.
%
%
% NOTES:
%
% - Ensure that the slice color plotting is in 'texture' mode -
%      On the 'AllSlices' menu click 'Color Texture'. No indication will
%      be made on this menu to show that it has been selected, but you can
%      see the result if you right-click on an arrow indicating a slice on
%      the graphics window.
%
% - To set the default for future Sliceomatic sessions -
%      On the 'Object_Defaults' menu select 'Slice Color Texture'

% RAE 25/3/2010

[figureHandle_, axesHandle_, plotHandle_] = sliceomatic_overview(sqw(w),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
