function dm(win,varargin)
% Plot markers for 1d dataset.
%
%   >> dm(win)
%   >> dm(win,xlo,xhi);
%   >> dm(win,xlo,xhi,ylo,yhi);
% Or:
%   >> dm(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'Color','red');
%
% See help for libisis/dm for more details of more options

% R.A. Ewings 14/10/2008

dm(sqw(win),varargin{:});
