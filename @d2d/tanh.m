function wout = tanh(win)
%--- Help for d2d/tanh.m---
% call syntax: dataset_2d = tanh(a)
%
% takes the hyperbolic tangent of a d2d object
%
% inputs: a = d2d object 
%
% output: d2d object.. dataset_2d = tanh(a)
wout = dnd_data_op(win, @tanh, 'd2d' , 2);

