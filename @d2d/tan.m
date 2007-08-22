function wout = tan(win)
%--- Help for d2d/cos.m---
% call syntax: dataset_2d = tan(a)
%
% takes the tangent of a d2d object
%
% inputs: a = d2d object 
%
% output: d2d object.. dataset_2d = tan(a)
wout = dnd_data_op(win, @tan, 'd2d' , 2);
