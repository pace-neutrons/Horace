function [wout] = scale_p1(win, varargin)
% Multiply the p1-axis by the factor fac
%
% Syntax:
%   >> w_out = scale_p1 (w_in, fac)
%
% See libisis documentation on scale_x for advanced usage.

wout = dnd_data_op(win, @scale_x, 'd2d' , 2, varargin{:});