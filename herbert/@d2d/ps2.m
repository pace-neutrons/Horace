function [figureHandle, axesHandle, plotHandle] = ps2(win,varargin)
% Surface plot for 2D dataset
%
%   >> ps2(win)
%   >> ps2(win,xlo,xhi)
%   >> ps2(win,xlo,xhi,ylo,yhi)
%
% See help for libisis/ps2 for more details of other options

% R.A. Ewings 14/10/2008

[figureHandle_, axesHandle_, plotHandle_] = ps2(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
