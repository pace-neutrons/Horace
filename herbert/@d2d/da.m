function [figureHandle, axesHandle, plotHandle] = da(win,varargin)
% Area plot for 2D dataset
%
%   >> da(win)
%   >> da(win,xlo,xhi)
%   >> da(win,xlo,xhi,ylo,yhi)
% Or:
%   >> da(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'colormap','bone')
% etc.
%
% See help for libisis\da for more details of other options

% R.A. Ewings 14/10/2008

[figureHandle_, axesHandle_, plotHandle_] = da(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
