function wout = sigvar (w)
% Create sigvar object from sqw object
% 
%   >> wout = sigvar (w)

% Original author: T.G.Perring
%
% $Revision: 259 $ ($Date: 2009-08-18 13:03:04 +0100 (Tue, 18 Aug 2009) $)

wout = sigvar(w.data.s, w.data.e);
