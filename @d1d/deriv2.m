function wout = deriv2(win)
%--- deriv2 - second derivative of d1d object ---
% call syntax: dataset_1d = deriv2(a)
%
% Takes the numerical second derivative of a d1d object
%
% inputs: a = d1d  object 
%
% output: d1d object
%
% if a is an array, dataset_1d will be an array such that dataset_1d(i) =
% deriv2(a(i))
%
% See libisis documentation for advanced syntaxes
wout = dnd_data_op(win, @deriv2, 'd1d' , 1);
