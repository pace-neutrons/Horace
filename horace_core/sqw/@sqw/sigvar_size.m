function sz = sigvar_size (w)
% Find size of signal array in sqw object
% 
%   >> sz = sigvar_size (w)

% Original author: T.G.Perring
%
% $Revision:: 1758 ($Date:: 2019-12-16 18:18:50 +0000 (Mon, 16 Dec 2019) $)

sz = size(w.data.s);

