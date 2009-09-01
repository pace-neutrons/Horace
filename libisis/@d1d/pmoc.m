function pmoc(win,varargin)
%
% pmoc(win,varargin)
% Libisis pmoc command - overplot markers of a 1d dataset on an existing
% figure, irrespective of its type. If no figure window open nothing happens.
%
% Optional inputs:
% pmoc(win);
% pmoc(win,'color','red');
%
% see help for libisis\pmoc for more details of options
%
% R.A. Ewings 14/10/2008

nd=dimensions(win);

if nd~=1
    error('Error - pmoc only works for 1d datasets');
end

pmoc(IXTdataset_1d(win),varargin{:});