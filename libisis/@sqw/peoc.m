function peoc(win,varargin)
%
% peoc(win,varargin)
% Libisis peoc command - overplot errorbars of a 1d dataset on an existing
% figure, irrespective of its type. If no figure window open nothing happens.
%
% Optional inputs:
% peoc(win);
% peoc(win,'color','red');
%
% see help for libisis\peoc for more details of options
%
% R.A. Ewings 14/10/2008

nd=dimensions(win);

if nd~=1
    error('Error - peoc only works for 1d datasets');
end

peoc(IXTdataset_1d(win),varargin{:});