function wout = sinh(win)
%--- Help for d2d/cos.m---
% call syntax: dataset_2d = sinh(a)
%
% takes the hyperbolic sine of a d2d object
%
% inputs: a = d2d object 
%
% output: d2d object.. dataset_2d = sinh(a)
wout = dnd_data_op(win, @sinh, 'd2d' , 2);
