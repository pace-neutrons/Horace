function [figureHandle, axesHandle, plotHandle] = sliceomatic_overview(w,varargin)
% Plots d3d object using sliceomatic with view straight down one of the axes
%
%   >> sliceomatic_overview(w)        % down third (vertical) axis
%   >> sliceomatic_overview(w,axis)   % down axis of choice (axis=1,2 or 3)
% 
%   w       d3d object
%   axis    integer in the range 1 to 3, to specify which axis to view along
%
% Do a sliceomatic plot, but set the axes so that we look straight down the
% 3rd (vertical) axis, so that when the slider is moved we get a series of
% what appear to be 2d slices.
%
% To get handles to the graphics figure:
%   >> [figureHandle_, axesHandle_, plotHandle_] = sliceomatic(w)

% RAE 25/3/2010

[figureHandle_, axesHandle_, plotHandle_] = sliceomatic_overview(sqw(w),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
