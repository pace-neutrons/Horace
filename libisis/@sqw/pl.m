function pl(win,varargin)
%
% pl(win,varargin)
% Libisis pl command - overplot data line of a 1d dataset on an existing
% figure. If no figure window open nothing happens.
%
% Optional inputs:
% pl(win);
% pl(win,'color','red');
%
% see help for libisis\pl for more details of options
%
% R.A. Ewings 14/10/2008

nd=dimensions(win);

if nd~=1
    error('Error - pl only works for 1d datasets');
end

pl(IXTdataset_1d(win),varargin{:});