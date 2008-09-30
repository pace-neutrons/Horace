function sz = sigvar_size (w)
% Find size of signal array in sqw object
% 
%   >> sz = sigvar_size (w)

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

if is_sqw_type(w)
    sz = size(w.data.s);
else
    sz = size(w.s);
end
