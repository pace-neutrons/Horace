function [idx_lng,minmax_idx] = long_idx(idx_short,minmax_idx)
%long_idx  construct long index build from array or cellarray of indices in
% 1 to 3 dimensions to use in data compression and pixels identification
%
% Input:
%  idx_short
%     either -- [ND x M] array of short indices where ND describes number
%               of box dimensions and M is the number of short indices to
%               convert to long for each dimension. ND currently selected
%               to be 3, though can be modified in a future.
%     or     -- ND element cellarray of 1 dimensional arrays representing
%               indices to process. The indices are interpreted as indices
%               along integer axis points of ND-dimensional box.
% Optional:
% minmax_idx -- [ND x 2] array of min-max values for input indices.
%               where minmax_idx(:,1) represent minimal and minmax_idx(:,2)
%               maximal values of input index array.
%               If not provided, this value is calulated from input indices
%               using minmax function.
%Returns:
%  idx_lng  -- linear indices of the n-dimensional box build on input
%              indices provided.
%

if nargin<2
    if iscell(idx_short)
        minmax_cell =  cellfun(@(x)min_max(x(:)'),idx_short,'UniformOutput',false);
        minmax_idx  =  cat(1,minmax_cell{:});
    else
        minmax_idx = min_max(idx_short);
    end
end


sz  = minmax_idx(:,2)-minmax_idx(:,1)+1;
if iscell(idx_short)
    ii = 1:numel(sz);
    idx_short = arrayfun(@(ii)(idx_short{ii}-minmax_idx(ii,1)+1),ii,'UniformOutput',false);
    idx_lng   = uint64(sub2ind(sz',idx_short{:}));
else
    idx_short = idx_short-minmax_idx(:,1)+1;
    idx_lng   = uint64(sub2ind(sz',idx_short(1,:),idx_short(2,:),idx_short(3,:)));
end