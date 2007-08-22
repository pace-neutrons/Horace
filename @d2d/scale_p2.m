function [wout] = scale_p2(win, varargin)
% d2d/SCALE_P2 - Multiplies the p2-dimension by the factor fac
%
% Syntax:
%   >> w_out = scale_y (w_in, fac)
%
% See libisis documentation on scale for advanced usage. 

% Catch trivial case of single input, or non-numeric scale factor:
wout = dnd_data_op(win, @scale_y, 'd2d' , 2, varargin{:});