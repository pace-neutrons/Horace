function [figureHandle_, axesHandle_, plotHandle_] = pd(win,varargin)
% Overplot errorbars, markers and lines for a 1d dataset on an existing figure.
%
% Optional inputs:
%   >> pd(win);
%   >> pd(win,'color','red');
%
% See help for libisis\pd for more details of further options

% R.A. Ewings 14/10/2008

[figureHandle_, axesHandle_, plotHandle_] = pd(sqw(win),varargin{:});
