function ds(win,varargin)
%
% ds(win,varargin)
% Libisis ds command - surface plot for 2d dataset.
%
% Optional inputs:
% ds(win,xlo,xhi);
% ds(win,xlo,xhi,ylo,yhi);
% or:
% ds(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'Colormap','jet');
%
% see help for libisis\ds for more details of options
%
% R.A. Ewings 14/10/2008

nd=dimensions(win);

if nd~=2
    error('Error - ds only works for 2d datasets');
end

ds(IXTdataset_2d(win),varargin{:});