function mp(win,varargin)
% Multiplot data ('waterfall' plot)
%
%   >> mp(win)
%   >> mp(win,xlo,xhi);
%   >> mp(win,xlo,xhi,ylo,yhi);
% or
%   >> mp(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'color','red'); etc
%
% See help for libisis\mp for more details of options
%
% R.A. Ewings 14/10/2008

mp(sqw(win),varargin{:});
