function wout = sin(win)
%--- Help for d2d/sin.m---
% call syntax: dataset_2d = sin(a)
%
% Takes the sine of a d2d object
%
% inputs: a= d2d object 
%
% output: d2d object... sin(a)
wout = dnd_data_op(win, @sin, 'd2d' , 2);
