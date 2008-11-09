function da(win,varargin)
%
% da(win,varargin)
% Libisis da command - area colour plot for 2d dataset
%
% Optional inputs:
% da(win,xlo,xhi);
% da(win,xlo,xhi,ylo,yhi);
%
% Or:
% da(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'colormap','bone');
%
% see help for libisis\da for more details of options
%
% R.A. Ewings 14/10/2008

nd=dimensions(win);

if nd~=2
    error('Error - da only works for 2d datasets');
end

da(IXTdataset_2d(win),varargin{:});