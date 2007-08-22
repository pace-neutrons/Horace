function wout = log(win)
%--- Help for d1d/log.m---
% call syntax: dataset_1d = log(a)
%
% takes the logarithm of a d1d object
%
% inputs: a = d1d object 
%
% output: d1d object.. dataset_1d = log(a)


wout = dnd_data_op(win, @log, 'd1d' , 1);
