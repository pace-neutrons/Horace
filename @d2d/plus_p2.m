function wout = plus_p2(a,b)
%--- Help for d2d/plus_p2.m---
% call syntax: dataset_2d = plus_p2(a,b)
%
% adds either a dataset_1d or a 1-d array to each column of an d2d
% object
%
% inputs: a = d1d object , b = 1-d array or d1d object
%
% output: d1d object
%
% see libisis documentation on plus_p2 for more information. 

wout = dnd_binary_op(a, b, @plus_y, 'd2d', 2);