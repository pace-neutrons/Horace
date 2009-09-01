function sqw_type = is_sqw_type(w)
% Determine if sqw type object or dnd type object
% 
%   >> sqw_type = is_sqw_type(w)

% Original author: T.G.Perring
%
% $Revision: 259 $ ($Date: 2009-08-18 13:03:04 +0100 (Tue, 18 Aug 2009) $)

if isfield(w.data,'pix')
    sqw_type = true;
else
    sqw_type = false;
end
