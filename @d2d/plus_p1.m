function wout = plus_p1(a,b)
%--- Help for d2d/plus_p1.m---
% call syntax: dataset_2d = plus_p1(a,b)
%
% adds either a dataset_1d or a 1-d numeric array to each row of an  d2d
% object
%
% inputs: a = d2d object , b = 1-d array or d1d object
%
% output: d2d object
%
% This has the same properties as plus_x in Libisis. 

wout = dnd_binary_op(a, b, @plus_x, 'd2d', 2);