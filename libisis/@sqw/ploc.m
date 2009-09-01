function ploc(win,varargin)
%
% ploc(win,varargin)
% Libisis ploc command - overplot line of a 1d dataset on an existing
% figure, irrespective of its type. If no figure window open nothing happens.
%
% Optional inputs:
% ploc(win);
% ploc(win,'color','red');
%
% see help for libisis\ploc for more details of options
%
% R.A. Ewings 14/10/2008

nd=dimensions(win);

if nd~=1
    error('Error - ploc only works for 1d datasets');
end

ploc(IXTdataset_1d(win),varargin{:});