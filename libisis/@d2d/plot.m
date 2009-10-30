function [figureHandle_, axesHandle_, plotHandle_] = plot(win,varargin)
% Plot d2d object using sqw gateway
%
%   >> plot(win)
%
% Equivalent to;
%   >> da(win)              % 2D dataset
%

% R.A. Ewings 9/1/2009

[figureHandle_, axesHandle_, plotHandle_] = plot(sqw(win),varargin{:});
