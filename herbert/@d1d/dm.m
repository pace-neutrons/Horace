function [figureHandle, axesHandle, plotHandle] = dm(win,varargin)
% Plot markers for 1d dataset.
%
%   >> dm(win)
%   >> dm(win,xlo,xhi)
%   >> dm(win,xlo,xhi,ylo,yhi)
% Or:
%   >> dm(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'Color','red')
% etc.
%
% See help for libisis/dm for more details of more options

% R.A. Ewings 14/10/2008

[figureHandle_, axesHandle_, plotHandle_] = dm(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
