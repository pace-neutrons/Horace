function wout = sigvar (w)
% Create sigvar object from sqw object
% 
%   >> wout = sigvar (w)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

wout = sigvar(w.data.s, w.data.e);
