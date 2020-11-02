function sz = sigvar_size (w)
% Find size of signal array in sqw object
% 
%   >> sz = sigvar_size (w)

% Original author: T.G.Perring
%
% $Revision:: 1759 ($Date:: 2020-02-10 16:06:00 +0000 (Mon, 10 Feb 2020) $)

sz = size(w.data.s);

