function pd(win,varargin)
%
% pd(win,varargin)
% Libisis pd command - overplot markers and errorbars of 1d dataset on an existing
% figure. If no figure window open nothing happens.
%
% Optional inputs:
% pd(win);
% pd(win,'color','red');
%
% see help for libisis\pd for more details of options
%
% R.A. Ewings 14/10/2008

nd=dimensions(win);

if nd~=1
    error('Error - pd only works for 1d datasets');
end

pd(IXTdataset_1d(win),varargin{:});