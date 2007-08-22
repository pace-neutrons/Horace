function wout = shift_p2(win,varargin)
%--- Help for d2d/shift_p2.m---
% call syntax: dataset_2d = shift_p2(a,y_shift)
%
% Shifts the y-array of an d2d object 'a' to the right by the amount
% 'y_shift'
%
% inputs: 
%       a:              d2d object
%       y_shift:        Amount to shift a data by
%
% output: 
%       dataset_2d:      d2d object 
%
% This function mirrors the libisis shifty function. 
wout = dnd_data_op(win, @shifty, 'd2d' , 2, varargin{:});
