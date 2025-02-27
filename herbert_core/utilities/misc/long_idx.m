function [idx_lng,minmax_idx] = long_idx(idx_short,minmax_idx)
%long_idx  construct long index build from array or cellarray of indices in
% 1 to 3 dimensions to use in data compression and pixels identification
%
% Input:
%  idx_short
%     either -- [N x numel] array of short indices
%     or     -- N element cellarray of 1 dimensional arrays representing
%               indices to process. The indices are interpreted as axis of
%               N-dimensional box. In this case N currenty implemented to
%               be in the range [1, 3].
% Optional:
% minmax_idx -- [N x 2] array of min-max values for input indices.
%               where minmax_idx(:,1) represent minimal and minmax_idx(:,2)
%               maximal values of input index array.
%               If not provided, this value is calulated from input indices
%               using minmax function.
%Returns:
%  idx_lng  -- linear indices of the n-dimensional box build on input
%              indices provided.
%
if iscell(idx_short)
    sz = numel(idx_short);
    switch(sz)
        case(1)
            if nargin<2
                minmax_idx = min_max(idx_short);
            end
            idx_lng = idx_short{1}-minmax_idx(1,1);
            return;
        case(2)
            [X,Y]=ndgrid(idx_short{:});
            idx_short = [X(:),Y(:)]';
        case(3)
            [X,Y,Z]=ndgrid(idx_short{:});
            idx_short = [X(:),Y(:),Z(:)]';
        otherwise
            error('HERBERT:utilities:not_implemented', ...
                ['long indices are not implemented for data in more than' ...
                ' 3 dimensions. Provided: %d dimensions'], ...
                sz);
    end
end

if nargin<2
    minmax_idx = min_max(idx_short);
end
% Explicit form
%scale1 = minmax_rng(1,2) -minmax_rng(1,1)+1;
%scale2 = minmax_rng(2,2) -minmax_rng(2,1)+1;
%idx = idx_short(1,:)-minmax_rng(1,1)+ scale1*(idx_short(2,:)-minmax_rng(2,1)+scale2*(idx_short(3,:)-minmax_rng(3,1)));

% more generic form
scale = [1;minmax_idx(:,2)-minmax_idx(:,1)+1];
scale = cumprod(scale);
idx = scale(1:end-1)'*(idx_short-minmax_idx(:,1));
if max(idx)>intmax("uint64")
    error('HERBERT:utilities:invalid_argument', [...
        'long run index exceeds maximal uint64 value so you can not accurately define it.'...
        ' Contact Horace developers for help with dealing with this issue']);
end
idx_lng = uint64(idx);
end