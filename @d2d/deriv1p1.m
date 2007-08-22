function wout = deriv1p1(win)
%--- Help for d2d/deriv1p1.m---
% call syntax: dataset_2d = deriv1p1(a)
%
% Takes the numerical first derivative  along p1 dimension of a d2d object
%
% inputs: a = d2d object 
%
% output: d2d object
%
% This function has the same properties as the libisis deriv1x function.
% See libisis documentation for more details.

wout = dnd_data_op(win, @deriv1x, 'd2d' , 2);
