function idx_short = short_from_long_idx(idx_long,minmax_idx)
%short_from_long_idx  the routine inverse to long_idx and used to obtain
% array of short indices from long indices produced long_idx routine.
%
% Used mainly in debugging for fast conversion of long indices into more
% visible shor indices
%
% Input:
%  idx_long  -- 1-Dimensional array of long indices as pro
%
% minmax_idx -- [N x 2] array of min-max values of short output indices
%               previously produced by long_idx routine.
%
%Returns:
%  idx_short -- array of short linear indices of the N-dimensional box
%               build with ranges defined nu minmax_idx array


scale = [1;minmax_idx(:,2)-minmax_idx(:,1)+1];
scale = cumprod(scale);
n_dims = numel(scale)-1;


remain = idx_long;
idx_short = zeros(n_dims,numel(idx_long));
for nd=n_dims:-1:1
    idx_short(nd,:) = floor(remain/scale(nd));
    remain = remain -idx_short(nd,:)*scale(nd);
    idx_short(nd,:) = idx_short(nd,:)+minmax_idx(nd,1);
end
