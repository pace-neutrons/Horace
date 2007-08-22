function [wout] = scale(win, varargin)
% Multiply the p1 and p2 axes by the factors fac_x and fac_y
%
% Syntax:
%   >> w_out = scale (w_in, fac_x, fac_y)
%
% See libisis documentation on scale for advanced usage.

% Catch trivial case:
wout = dnd_data_op(win, @scale, 'd2d' , 2, varargin{:});
