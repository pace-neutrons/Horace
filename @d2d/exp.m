function wout = exp(win)
%--- Help for d2d/exp.m---
% call syntax: dataset_2d = exp(a)
%
% takes the exponent of a d2d object
%
% inputs: a = d2d object 
%
% output: d2d object.. dataset_2d = exp(a)
wout = dnd_data_op(win, @exp, 'd2d' , 2);