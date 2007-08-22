function wout = times_p2(a,b)
%--- Help for d2d/times_p2.m---
% call syntax: dataset_2d = times_p2(a,b)
%
% multiplies either a dataset_1d or a 1-d array with each column of an
% d2d
% object
%
% When multiplying by a 1d array (or d1d) the division is done such
% that
%
% dataset_2d(i).s(j,k) = ww(i).s(j,k) * n(k) 
%
% where n is either the 1d numeric array or signal data in the
% d1d
%
% inputs: a = d2d object , b = 1-d array or d1d object
%
% output: d2d object
%
% This function has the same properties as libisis times_y. See libisis
% documentation for details. 

wout = dnd_binary_op(a, b, @times_y, 'd2d', 2);