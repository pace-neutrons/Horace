function dh(win,varargin)
% Plot histogram of a 1d dataset.
%
%   >> dh(win)
%   >> dh(win,xlo,xhi);
%   >> dh(win,xlo,xhi,ylo,yhi);
% Or:
%   >> dh(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'Color','red');
%
% See help for libisis/dh for more details of more options

% R.A. Ewings 14/10/2008

dh(sqw(win),varargin{:});
