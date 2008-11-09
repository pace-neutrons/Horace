function dp(win,varargin)
%
% dp(win,varargin)
% Libisis dp command - plot errorbars and markers for 1d dataset.
%
% Optional inputs:
% dp(win,xlo,xhi);
% dp(win,xlo,xhi,ylo,yhi);
% or:
% dp(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'Color','red');
%
% see help for libisis\dp for more details of options
%
% R.A. Ewings 14/10/2008

nd=dimensions(win);

if nd~=1
    error('Error - dp only works for 1d datasets');
end

dp(IXTdataset_1d(win),varargin{:});