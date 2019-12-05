function wout = sigvar (w)
% Create sigvar object from sqw object
% 
%   >> wout = sigvar (w)

% Original author: T.G.Perring
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)

wout = sigvar(w.data.s, w.data.e);

