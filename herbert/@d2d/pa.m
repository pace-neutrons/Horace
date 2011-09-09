function [figureHandle, axesHandle, plotHandle] = pa(win,varargin)
% Area plot for 2D dataset
%
%   >> pa(win)
%   >> pa(win,xlo,xhi)
%   >> pa(win,xlo,xhi,ylo,yhi)
%
% See help for libisis\pa for more details of other options

% R.A. Ewings 14/10/2008

[figureHandle_, axesHandle_, plotHandle_] = pa(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
