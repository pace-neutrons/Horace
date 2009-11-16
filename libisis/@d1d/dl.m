function [figureHandle_, axesHandle_, plotHandle_] = dl(win,varargin)
% Plot line through data for 1d dataset.
%
%   >> dl(win)
%   >> dl(win,xlo,xhi);
%   >> dl(win,xlo,xhi,ylo,yhi);
% Or:
%   >> dl(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'Color','red');
%
% See help for libisis/dl for more details of more options

% R.A. Ewings 14/10/2008

[figureHandle_, axesHandle_, plotHandle_] = dl(sqw(win),varargin{:});
