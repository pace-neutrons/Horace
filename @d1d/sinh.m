function wout = sinh(win)
%--- Help for d1d/cos.m---
% call syntax: dataset_1d = sinh(a)
%
% takes the hyperbolic sine of a d1d object
%
% inputs: a = d1d object 
%
% output: d1d object.. dataset_1d = sinh(a)
%
% The input dataset is converted to a libisis IXTdataset_1d and then
% operated upon. It is then converted back. 
wout = dnd_data_op(win, @sinh, 'd1d' , 1);
