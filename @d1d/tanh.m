function wout = tanh(win)
%--- Help for d1d/tanh.m---
% call syntax: dataset = tanh(a)
%
% takes the hyperbolic tangent of a d1d object
%
% inputs: a = d1d object 
%
% output: d1d object.. dataset_1d = tanh(a)
%
% The input dataset is converted to a libisis IXTdataset_1d and then
% operated upon. It is then converted back. 
wout = dnd_data_op(win, @tanh, 'd1d' , 1);
