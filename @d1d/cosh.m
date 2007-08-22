function wout = cosh(win)
%--- Help for d1d/cosh.m---
% call syntax: dataset_1d = cosh(a)
%
% takes the hyperbolic cosine of a d1d object
%
% inputs: a = d1d object 
%
% output: d1d object.. dataset_1d = cosh(a)

wout = dnd_data_op(win, @cosh, 'd1d' , 1);