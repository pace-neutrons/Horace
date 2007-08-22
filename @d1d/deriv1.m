function wout = deriv1(win)
%--- deriv1 derivative function for d1d objects in libisisexc---
% call syntax: dataset_1d = deriv1(a)
%
% Takes the numerical first derivative of a d1d object
%
% inputs: a = d1d object 
%
% output: d1d object
%
% if given an array of dataset_1d, returns an array of dataset_1d such that
% dataset_1d(i) = deriv1(a(i))
%
% e.g. result = deriv1([w1, w2]) 
% this gives result(1) = the derivative of w1, result(2) = derivative of w2
%
% see libisis documentation for advanced syntaxes
wout = dnd_data_op(win, @deriv1, 'd1d' , 1);
