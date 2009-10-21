function de(win,varargin)
% Plot errorbars for 1d dataset.
%
%   >> de(win)
%   >> de(win,xlo,xhi);
%   >> de(win,xlo,xhi,ylo,yhi);
% Or:
%   >> de(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'Color','red');
%
% See help for libisis/de for more details of more options

% R.A. Ewings 14/10/2008

de(sqw(win),varargin{:});
