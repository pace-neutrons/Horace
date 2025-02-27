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


sizes = minmax_idx(:,2)-minmax_idx(:,1)+1;
nt = numel(sizes);
switch(nt)
    case(1)
        idx_short = idx_long+minmax_idx(1,1)-1;
    case(2)
        [ix,iy] = ind2sub(sizes,idx_long+1);
        idx_short = [ix+minmax_idx(1,1)-1;iy+minmax_idx(2,1)-1];
    case(3)
        [ix,iy,iz] = ind2sub(sizes,idx_long+1);
        idx_short = [ix+minmax_idx(1,1)-1;iy+minmax_idx(2,1)-1;iz+minmax_idx(3,1)-1];
    otherwise
        error('HERBERT:utilies:not_implemented', ...
            'Processing Indices for more than 3 dimension have not been yet implemented')
end
