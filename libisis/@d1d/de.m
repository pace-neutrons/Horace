function [figureHandle, axesHandle, plotHandle] = de(win,varargin)
% Plot errorbars for 1d dataset.
%
%   >> de(win)
%   >> de(win,xlo,xhi)
%   >> de(win,xlo,xhi,ylo,yhi)
% Or:
%   >> de(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'Color','red')
% etc.
%
% See help for libisis/de for more details of more options

% R.A. Ewings 14/10/2008

[figureHandle_, axesHandle_, plotHandle_] = de(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
