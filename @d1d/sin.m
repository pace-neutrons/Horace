function wout = sin(win)
%--- Help for d1d/sin.m---
% call syntax: dataset_1d = sin(a)
%
% Takes the sine of a d1d object
%
% inputs: a= d1d object 
%
% output: d1d object... sin(a)
%
% The input dataset is converted to a libisis IXTdataset_1d and then
% operated upon. It is then converted back. 

wout = dnd_data_op(win, @sin, 'd1d' , 1);
