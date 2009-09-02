function sqw_type = is_sqw_type(w)
% Determine if sqw type object or dnd type object
% 
%   >> sqw_type = is_sqw_type(w)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

if isfield(w.data,'pix')
    sqw_type = true;
else
    sqw_type = false;
end
