function wout = deriv2p2(win)
%--- Help for d2d/deriv2p2.m---
% call syntax: dataset_2d = deriv2p2(a)
%
% Takes the numerical second derivative along p2 dimension of a d2d object
%
% inputs: a = d2d object 
%
% output: d2d object
%
% This function has the same properties as the libisis deriv2y function.
% See libisis documentation for more details.
wout = dnd_data_op(win, @deriv2y, 'd2d' , 2);