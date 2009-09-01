function dd(win,varargin)
% Plot errorbars, markers, and line through data for 1d dataset.
%
%   >> dd(win)
%   >> dd(win,xlo,xhi);
%   >> dd(win,xlo,xhi,ylo,yhi);
% Or:
%   >> dd(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'Color','red');
%
% See help for libisis/dd for more details of more options

% R.A. Ewings 14/10/2008

dd(sqw(win),varargin{:});
