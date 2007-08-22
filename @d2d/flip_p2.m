function wout = flip_p2(win)
% Reverses the order of the points along the p2 axis.
%
%   >> wout = flip_p2(win)
%
% Handy if the data has been read from a file in which p2
% is in decreasing order; many routines assume that the data is
% in increasing p2 order.

wout = dnd_data_op(win, @flip_y, 'd2d' , 2);