function pe(win,varargin)
%
% pe(win,varargin)
% Libisis pe command - overplot errorbars of a 1d dataset on an existing
% figure. If no figure window open nothing happens.
%
% Optional inputs:
% pe(win);
% pe(win,'color','red');
%
% see help for libisis\pe for more details of options
%
% R.A. Ewings 14/10/2008

nd=dimensions(win);

if nd~=1
    error('Error - pe only works for 1d datasets');
end

pe(IXTdataset_1d(win),varargin{:});