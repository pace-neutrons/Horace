function [figureHandle, axesHandle, plotHandle] = plot(win,varargin)
% Plot 1D, 2D or 3D sqw object
%
%   >> plot(win)
%
% Equivalent to;
%   >> dp(win)              % 1D dataset
%
%   >> da(win)              % 2D dataset
%
%   >> sliceomatic(win)     % 3D dataset


% R.A. Ewings 14/10/2008

nd=dimensions(win); %find out what dimensionality dataset we have.

if nd==0 || nd>=4
    error('Dataset is neither 1d, 2d, nor 3d, so cannot be plotted');
end

if nd==1
    [figureHandle_, axesHandle_, plotHandle_] = dp(win,varargin{:});
elseif nd==2
    [figureHandle_, axesHandle_, plotHandle_] = da(win,varargin{:});
else
    sliceomatic(win,varargin{:});
end

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
