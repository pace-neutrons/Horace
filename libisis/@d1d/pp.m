function pp(win,varargin)
%
% pp(win,varargin)
% Libisis pp command - overplot data markers and errorbars of a 1d dataset 
% on an existing figure. If no figure window open nothing happens.
%
% Optional inputs:
% pp(win);
% pp(win,'color','red');
%
% see help for libisis\pp for more details of options
%
% R.A. Ewings 14/10/2008

nd=dimensions(win);

if nd~=1
    error('Error - pp only works for 1d datasets');
end

pp(IXTdataset_1d(win),varargin{:});