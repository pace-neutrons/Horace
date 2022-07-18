function wout = sigvar(w)
% Create sigvar object from sqw object
%
%   >> wout = sigvar (w)

wout = sigvar(w.data_.s, w.data_.e);

