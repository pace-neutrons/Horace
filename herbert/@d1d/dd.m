function [figureHandle, axesHandle, plotHandle] = dd(win,varargin)
% Plot errorbars, markers, and line through data for 1d dataset.
%
%   >> dd(win)
%   >> dd(win,xlo,xhi)
%   >> dd(win,xlo,xhi,ylo,yhi)
% Or:
%   >> dd(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'Color','red')
% etc.
%
% See help for libisis/dd for more details of more options

% R.A. Ewings 14/10/2008

[figureHandle_, axesHandle_, plotHandle_] = dd(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
