function plot(win,varargin)
% Plot d2d object using sqw gateway
%
%   >> plot(win)
%
% Equivalent to;
%   >> da(win)              % 2D dataset
%

% R.A. Ewings 9/1/2009

plot(sqw(win),varargin{:});
