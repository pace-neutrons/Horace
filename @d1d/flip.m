function wout = flip(win)
% Reverses the order of the points along the x axis.
%
%   >> wout = flip(win)
%
% Handy if the data has been read from a file in which x
% is in decreasing order; many routines assume that the data is
% in increasing x order.

wout = dnd_data_op(win, @flip, 'd1d' , 1);