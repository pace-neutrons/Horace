function wout = minus_p2(a,b)
%--- Help for d2d/minus_p2.m---
% call syntax: dataset_2d = minus_p2(a,b)
%
% subtracts either a dataset_1d or a 1-d array from each column of an  d2d
% object
%
% inputs: a = d2d object , b = 1-d array or d1d object
%
% output: d2d object
%
% This has the same properties as minus_y in Libisis. See documentation for
% advanced use.

wout = dnd_binary_op(a, b, @minus_y, 'd2d', 2);