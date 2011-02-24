function [figureHandle, axesHandle, plotHandle] = mp(win,varargin)
% Multiplot data for array of 1D datasets
%
%   >> mp(win)
%   >> mp(win,xlo,xhi)
%   >> mp(win,xlo,xhi,ylo,yhi)
% Or:
%   >> mp(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'color','red')
% etc.
%
% See help for libisis/mp for more details of other options

% R.A. Ewings 14/10/2008

[figureHandle_, axesHandle_, plotHandle_] = mp(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
