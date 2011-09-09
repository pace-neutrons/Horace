function [figureHandle, axesHandle, plotHandle] = dl(win,varargin)
% Plot line through data for 1d dataset.
%
%   >> dl(win)
%   >> dl(win,xlo,xhi)
%   >> dl(win,xlo,xhi,ylo,yhi)
% Or:
%   >> dl(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'Color','red')
% etc.
%
% See help for libisis/dl for more details of more options

% R.A. Ewings 14/10/2008

[figureHandle_, axesHandle_, plotHandle_] = dl(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
