function fs_new = merge_adjacent_space_(fs)
% merge together free space which occurs after block removal and
% when blocks were located one after another (contiguous blocks).
% Get continuous chunks of space.
% Inputs:
% fs     -- 2 x n-elements array which defines free spaces fhere the first
%           row defines position of the block and the second row -- the size
%           of the gap. Block overlapping (e.g. fs(1,i)+fs(2,i)>fs(1,n)
%           for any i,n) is prohibited.
% Returns:
% fs_new  -- 2 x m-elements array (m<=n) of free spaces where all adjacent
%            blocks were merged together

%
[~,indx] = sort(fs(1,:));
fs = fs(:,indx);

start_pos   = fs(1,:);
block_sizes = fs(2,:);
end_pos = start_pos+block_sizes;
adjacent = [false,start_pos(2:end)==end_pos(1:end-1)];
if any(adjacent)
    ic = 1;
    fs_new = zeros(2,numel(start_pos)-sum(adjacent));
    for i=1:numel(start_pos)
        if adjacent(i)
            fs_new(2,ic-1) = fs_new(2,ic-1)+fs(2,i);
        else
            fs_new(1,ic) = fs(1,i);
            fs_new(2,ic) = fs(2,i);
            ic = ic+1;
        end
    end
else
    fs_new = fs;
end
