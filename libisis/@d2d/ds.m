function ds(win,varargin)
% Surface plot for 2D dataset
%
%   >> da(win)
%   >> da(win,xlo,xhi);
%   >> da(win,xlo,xhi,ylo,yhi);
% Or:
%   >> da(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'colormap','jet');
%
% See help for libisis/ds for more details of other options

% R.A. Ewings 14/10/2008

da(sqw(win),varargin{:});
