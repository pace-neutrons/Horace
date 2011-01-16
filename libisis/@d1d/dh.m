function [figureHandle, axesHandle, plotHandle] = dh(win,varargin)
% Plot histogram of a 1d dataset.
%
%   >> dh(win)
%   >> dh(win,xlo,xhi)
%   >> dh(win,xlo,xhi,ylo,yhi)
% Or:
%   >> dh(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'Color','red')
% etc.
%
% See help for libisis/dh for more details of more options

% R.A. Ewings 14/10/2008

[figureHandle_, axesHandle_, plotHandle_] = dh(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
