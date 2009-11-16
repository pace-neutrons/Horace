function [figureHandle_, axesHandle_, plotHandle_] = ph(win,varargin)
% Overplot histogram of a 1d dataset on an existing figure.
%
% Optional inputs:
%   >> ph(win);
%   >> ph(win,'color','red');
%
% See help for libisis\ph for more details of further options

% R.A. Ewings 14/10/2008

[figureHandle_, axesHandle_, plotHandle_] = ph(sqw(win),varargin{:});
