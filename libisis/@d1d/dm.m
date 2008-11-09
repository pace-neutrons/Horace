function dm(win,varargin)
%
% dm(win,varargin)
% Libisis dl command - marker plot for 1d dataset.
%
% Optional inputs:
% dm(win,xlo,xhi);
% dm(win,xlo,xhi,ylo,yhi);
% or:
% dm(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'Color','red');
%
% see help for libisis\dm for more details of options
%
% R.A. Ewings 14/10/2008

nd=dimensions(win);

if nd~=1
    error('Error - dm only works for 1d datasets');
end

dm(IXTdataset_1d(win),varargin{:});