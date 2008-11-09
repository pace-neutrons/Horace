function dd(win,varargin)
%
% dd(win,varargin)
% Libisis dd command - plot errorbars, markers, and line through data for
% 1d dataset.
%
% Optional inputs:
% dd(win,xlo,xhi);
% dd(win,xlo,xhi,ylo,yhi);
% or:
% dd(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'Color','red');
%
% see help for libisis\dd for more details of options
%
% R.A. Ewings 14/10/2008

nd=dimensions(win);

if nd~=1
    error('Error - dd only works for 1d datasets');
end

dd(IXTdataset_1d(win),varargin{:});