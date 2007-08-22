function wout = shift(win,varargin)
%--- shift  - shift a dataset 2d object in both x and y directions---
% call syntax: dataset_2d = shift(a,x_shift,y_shift)
%
% Shifts the x-array of an d2d object 'a' to the right by the amount
% 'x_shift' and the y-array by the amount 'y_shift'
%
% inputs: a= d2d object, x_shift = amount to shift the x-array data by, 
% y_shift = amount to shift a y array data by
%
% output: d2d object 
% 
% If d2d is an array then each dataset will be shifted by x_shift
% and y_shift. If x_shift and y_shift are arrays of the same length as the
% dataset then dataset_2d(i) will be shifted in x by x_shift(i) and y by
% y_shift(i)
%
% This function mirrors libisis shift function. See libisis documentation
% for details.

wout = dnd_data_op(win, @shift, 'd2d' , 2, varargin{:});
