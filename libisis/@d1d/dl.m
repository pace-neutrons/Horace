function dl(win,varargin)
%
% dl(win,varargin)
% Libisis dl command - line plot for 1d dataset.
%
% Optional inputs:
% dl(win,xlo,xhi);
% dl(win,xlo,xhi,ylo,yhi);
% or:
% dl(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'Color','red');
%
% see help for libisis\dl for more details of options
%
% R.A. Ewings 14/10/2008

nd=dimensions(win);

if nd~=1
    error('Error - dl only works for 1d datasets');
end

dl(IXTdataset_1d(win),varargin{:});