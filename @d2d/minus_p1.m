function wout = minus_p1(a,b)
%--- Help for d2d/minus_p1.m---
% call syntax: dataset_2d = minus_p1(a,b)
%
% subtracts either a dataset_1d or a 1-d array from each row of an  d2d
% object
%
% inputs: a = d2d object , b = 1-d array or d1d object
%
% output: d2d object.
%
% This has the same properties as minus_x in Libisis. See documentation for
% advanced use.

wout = dnd_binary_op(a, b, @minus_x, 'd2d', 2);