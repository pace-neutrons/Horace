function plot(win,varargin)
% Plot d1d object using sqw gateway
%
%   >> plot(win)
%
% Equivalent to;
%   >> dp(win)              % 1D dataset
%

% R.A. Ewings 9/1/2009

plot(sqw(win),varargin{:});
