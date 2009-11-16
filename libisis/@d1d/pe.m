function [figureHandle_, axesHandle_, plotHandle_] = pe(win,varargin)
% Overplot errorbars for a 1d dataset on an existing figure.
%
% Optional inputs:
%   >> pe(win);
%   >> pe(win,'color','red');
%
% See help for libisis\pe for more details of further options

% R.A. Ewings 14/10/2008

[figureHandle_, axesHandle_, plotHandle_] = pe(sqw(win),varargin{:});
