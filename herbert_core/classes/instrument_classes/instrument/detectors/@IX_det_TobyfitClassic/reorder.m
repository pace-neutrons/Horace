function obj_out = reorder (obj, ix)
% Reorder the detector elements according to an indexing array
%
%   >> obj_out = reorder (obj, ix)
%
% Input:
% ------
%   obj         Input object
%   ix          Index array
%
% Output:
% -------
%   obj_out     Output array such that all internal data has been reordered
%               so that the new order of detector elements is det_out = det(ix)


% Check indexing array is valid
ndet = obj.ndet;
[~,~,ix,perm] = is_integer_id(ix);
if ~(perm && numel(ix)==ndet)
    error('HERBERT:IX_det_TobyfitClassic:invalid_argument',...
        ['Index array is not a permutation of the integers 1 to the ',...
        'number of detector elements'])
end

% Reorder the detector arrays
obj_out = obj;
obj_out.dia_    = obj.dia_(ix);
obj_out.height_ = obj.height_(ix);
