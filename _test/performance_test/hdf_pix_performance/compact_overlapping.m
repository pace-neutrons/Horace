function [start_pos,block_size] = compact_overlapping(start_pos,block_size)
% function compacts together overlapping blocks and return the
% non-overlapping blocks with block union sizes;

end_pos = start_pos+block_size;

ignored = false(size(start_pos));
for i=1:numel(start_pos)-1
    if ignored(i)
        continue;
    end
    for j=i+1:numel(start_pos)
        if start_pos(j)<=end_pos(i) % overlaps or inside
            if end_pos(j)>end_pos(i) %ovelaps, extend block i
                end_pos(i)=end_pos(j);
            end
            ignored(j) = true;
        else
            break
        end
    end
end
start_pos  = start_pos(~ignored);
end_pos    = end_pos(~ignored);
block_size = end_pos -start_pos;
