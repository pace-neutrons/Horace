function wout = flip_p1(win)
% Reverses the order of the points along the p1 axis.
%
%   >> wout = flip_p1(win)
%
% Handy if the data has been read from a file in which p1
% is in decreasing order; many routines assume that the data is
% in increasing p1 order.

wout = dnd_data_op(win, @flip_x, 'd2d' , 2);

