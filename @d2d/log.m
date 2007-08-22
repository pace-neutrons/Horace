function wout = log(win)
%--- Help for d2d/log.m---
% call syntax: dataset_2d = log(a)
%
% takes the logarithm of a d2d object
%
% inputs: a = d2d object 
%
% output: d2d object.. dataset_2d = log(a)
wout = dnd_data_op(win, @log, 'd2d' , 2);