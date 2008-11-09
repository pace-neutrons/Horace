function ph(win,varargin)
%
% ph(win,varargin)
% Libisis ph command - overplot histogram of a 1d dataset on an existing
% figure. If no figure window open nothing happens.
%
% Optional inputs:
% ph(win);
% ph(win,'color','red');
%
% see help for libisis\ph for more details of options
%
% R.A. Ewings 14/10/2008

nd=dimensions(win);

if nd~=1
    error('Error - ph only works for 1d datasets');
end

ph(IXTdataset_1d(win),varargin{:});