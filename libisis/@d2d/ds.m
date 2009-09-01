function ds(win,varargin)
% Surface plot for 2D dataset
%
%   >> ds(win)
%   >> ds(win,xlo,xhi);
%   >> ds(win,xlo,xhi,ylo,yhi);
% Or:
%   >> ds(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'colormap','jet');
%
% See help for libisis/ds for more details of other options

% R.A. Ewings 14/10/2008

ds(sqw(win),varargin{:});
