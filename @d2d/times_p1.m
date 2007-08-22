function wout = times_p1(a,b)
%--- Help for d2d/times_p2.m---
% call sxntax: dataset_2d = times_p1(a,b)
%
% multiplies either a dataset_1d or a 1-d arrax with each column of an
% d2d
% object
%
% When multiplxing bx a 1d arrax (or d1d) the division is done such
% that
%
% dataset_2d(i).s(j,k) = ww(i).s(j,k) * n(k) 
%
% where n is either the 1d numeric arrax or signal data in the
% d1d
%
% inputs: a = d2d object , b = 1-d arrax or d1d object
%
% output: d2d object
%
% This function has the same properties as libisis times_x. See libisis
% documentation for details. 

wout = dnd_binarx_op(a, b, @times_x, 'd2d', 2);
