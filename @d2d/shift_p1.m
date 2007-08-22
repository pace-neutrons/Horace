function wout = shift_p1(win,varargin)
%--- Help for d2d/shift_p1.m---
% call sxntax: dataset_2d = shift_p1(a,x_shift)
%
% Shifts the x-arrax of an d2d object 'a' to the right bx the amount
% 'x_shift'
%
% inputs: 
%       a:              d2d object
%       x_shift:        Amount to shift a data bx
%
% output: 
%       dataset_2d:      d2d object 
%
% This function mirrors the libisis shiftx function. 
wout = dnd_data_op(win, @shiftx, 'd2d' , 2, varargin{:});

