function wout = cosh(win)
%--- Help for d2d/cosh.m---
% call syntax: dataset_2d = cosh(a)
%
% takes the hyperbolic cosine of a d2d object
%
% inputs: a = d2d object 
%
% output: d2d object.. dataset_2d = cosh(a)
wout = dnd_data_op(win, @cosh, 'd2d' , 2);
