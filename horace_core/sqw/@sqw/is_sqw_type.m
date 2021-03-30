function sqw_type = is_sqw_type(w)
% Determine if sqw type object or dnd type object
%
%   >> sqw_type = is_sqw_type(w)
%
% Input:
% ------
%   w           sqw-type or dnd-type sqw object or array of objects
%
% Output:
% -------
%   sqw_type    =true or =false (array)

% Original author: T.G.Perring
%
sqw_type=false(size(w));
for i=1:numel(w)
    if w(i).data.pix.num_pixels > 0
        sqw_type(i) = true;
    else
        sqw_type(i) = false;
    end
end

