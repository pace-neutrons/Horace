function wout = cos(win)
%--- Help for d1d/cos.m---
% call syntax: dataset_1d = cos(a)
%
% takes the cosine of a d1d object
%
% inputs: a = d1d object 
%
% output: d1d object.. dataset_1d = cos(a)

wout = dnd_data_op(win, @cos, 'd1d' , 1);
