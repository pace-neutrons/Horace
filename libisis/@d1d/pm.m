function pm(win,varargin)
%
% pm(win,varargin)
% Libisis pm command - overplot data markers of a 1d dataset on an existing
% figure. If no figure window open nothing happens.
%
% Optional inputs:
% pm(win);
% pm(win,'color','red');
%
% see help for libisis\pm for more details of options
%
% R.A. Ewings 14/10/2008

nd=dimensions(win);

if nd~=1
    error('Error - pm only works for 1d datasets');
end

pm(IXTdataset_1d(win),varargin{:});