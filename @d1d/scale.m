function [wout] = scale(win, varargin)
% Multiply the x-axis of an d1d by the factor fac
%
% Syntax:
%   >> w_out = scale (w_in, fac)
%
% The input dataset is converted to a libisis IXTdataset_1d and then
% operated upon. It is then converted back. 

wout = dnd_data_op(win, @scale, 'd1d' , 1, varargin{:});