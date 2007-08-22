function wout = unspike(win)
%--- Help for d2d/unspike.m---
% call syntax: dataset_2d = unspike(a)
%
% unspikes the signal data of an d2d object
%
% inputs: a = d2d object 
%
% output: d2d object.. dataset_2d = unspike(a)
%
% Definition of a spike: the spike differs from it's neighbours by at least
% a factor of 2 and is at least 5 standard deviations away from them
%
% spikes are replaced with an interpolated value
%
% See libisis doucmentation for advanced useage.

wout = dnd_data_op(win, @unspike, 'd2d' , 2);
