function wout = deriv2p1(win)
%--- Help for d2d/deriv2p1.m---
% call syntax: dataset_2d = deriv2p1(a)
%
% Takes the numerical second derivative along p1 dimension of a d2d object
%
% inputs: a = d2d object 
%
% output: d2d object
%
% This function has the same properties as the libisis deriv2x function.
% See libisis documentation for more details.
wout = dnd_data_op(win, @deriv2x, 'd2d' , 2);