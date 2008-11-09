function de(win,varargin)
%
% de(win,varargin)
% Libisis de command - plot errorbars for 1d dataset.
%
% Optional inputs:
% de(win,xlo,xhi);
% de(win,xlo,xhi,ylo,yhi);
% or:
% de(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'Color','red');
%
% see help for libisis\de for more details of options
%
% R.A. Ewings 14/10/2008

nd=dimensions(win);

if nd~=1
    error('Error - de only works for 1d datasets');
end

de(IXTdataset_1d(win),varargin{:});