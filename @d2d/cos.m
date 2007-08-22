function wout = cos(win)
%--- Help for IXTdataset_1d/cos.m---
% call syntax: dataset_2d = cos(a)
%
% takes the cosine of a d2d object
%
% inputs: a = d2d object 
%
% output: d2d object.. dataset_2d = cos(a)
wout = dnd_data_op(win, @cos, 'd2d' , 2);
