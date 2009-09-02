function sz = sigvar_size (w)
% Find size of signal array in sqw object
% 
%   >> sz = sigvar_size (w)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

sz = size(w.data.s);
