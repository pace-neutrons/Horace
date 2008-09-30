function sqw_type = is_sqw_type(w)
% Determine if sqw type object or dnd type object
% 
%   >> sqw_type = is_sqw_type(w)

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

if isfield(w.data,'pix')
    sqw_type = true;
else
    sqw_type = false;
end
