function sz = sigvar_size (w)
% Find size of signal array in sqw object
% 
%   >> sz = sigvar_size (w)

% Original author: T.G.Perring
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)

sz = size(w.data.s);
