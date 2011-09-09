function [figureHandle, axesHandle, plotHandle] = ds2(win,varargin)
% Surface plot for 2D dataset
%
%   >> ds2(win)
%   >> ds2(win,xlo,xhi)
%   >> ds2(win,xlo,xhi,ylo,yhi)
% Or:
%   >> ds2(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'colormap','jet')
% etc.
%
% See help for libisis/ds2 for more details of other options

% R.A. Ewings 14/10/2008

[figureHandle_, axesHandle_, plotHandle_] = ds2(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
