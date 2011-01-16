function [figureHandle, axesHandle, plotHandle] = sp(win,varargin)
% Stem plot (plot data as stems from x-y plane).
%
%   >> sp(win)
%   >> sp(win,xlo,xhi)
%   >> sp(win,xlo,xhi,ylo,yhi)
% or:
%   >> sp(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'color','red')
% etc.
%
% See help for libisis\sp for more details of options

% R.A. Ewings 14/10/2008

[figureHandle_, axesHandle_, plotHandle_] = sp(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
