function phoc(win,varargin)
%
% phoc(win,varargin)
% Libisis phoc command - overplot histogram of a 1d dataset on an existing
% figure, irrespective of its type. If no figure window open nothing happens.
%
% Optional inputs:
% phoc(win);
% phoc(win,'color','red');
%
% see help for libisis\phoc for more details of options
%
% R.A. Ewings 14/10/2008

nd=dimensions(win);

if nd~=1
    error('Error - phoc only works for 1d datasets');
end

phoc(IXTdataset_1d(win),varargin{:});