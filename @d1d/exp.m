function wout = exp(win)
%--- Help for d1d/exp.m---
% call syntax: dataset_1d = exp(a)
%
% takes the exponent of a d1d object
%
% inputs: a = d1d object 
%
% output: d1d object.. dataset_1d = exp(a)
wout = dnd_data_op(win, @exp, 'd1d' , 1);
