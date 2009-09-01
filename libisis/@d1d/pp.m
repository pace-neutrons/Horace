function pp(win,varargin)
% Overplot errorbars and markers for a 1d dataset on an existing figure.
%
% Optional inputs:
%   >> pp(win);
%   >> pp(win,'color','red');
%
% See help for libisis\pp for more details of further options

% R.A. Ewings 14/10/2008

pp(sqw(win),varargin{:});
