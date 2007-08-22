function wout = flip(win)
% Reverses the order of the points along the p1 and p2 axis.
%
%   >> wout = flip(win)
%
% Handy if the data has been read from a file in which p1 and p2
% are in decreasing order; many routines assume that the data is
% in increasing p1 and p2 order.
wout = dnd_data_op(win, @flip, 'd2d' , 2);