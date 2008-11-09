function dh(win,varargin)
%
% dh(win,varargin)
% Libisis dh command - histogram plot for 1d dataset.
%
% Optional inputs:
% dh(win,xlo,xhi);
% dh(win,xlo,xhi,ylo,yhi);
% or:
% dh(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'Color','red');
%
% see help for libisis\dh for more details of options
%
% R.A. Ewings 14/10/2008

nd=dimensions(win);

if nd~=1
    error('Error - dh only works for 1d datasets');
end

dh(IXTdataset_1d(win),varargin{:});