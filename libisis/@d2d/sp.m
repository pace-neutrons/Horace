function sp(win,varargin)
% Stem plot (plot data as stems from x-y plane).
%
%   >> sp(win)
%   >> sp(win,xlo,xhi);
%   >> sp(win,xlo,xhi,ylo,yhi);
% or:
%   >> sp(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'color','red');
%
% See help for libisis\sp for more details of options

% R.A. Ewings 14/10/2008

sp(sqw(win),varargin{:});
