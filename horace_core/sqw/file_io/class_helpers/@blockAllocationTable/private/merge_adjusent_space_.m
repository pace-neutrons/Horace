function fs_new = merge_adjusent_space_(fs)
% merge together free space which occurs after block removal and
% when blocks were located one after another. Get continuous chunks of
% space.
[~,indx] = sort(fs(1,:));
fs = fs(:,indx);

start_pos   = fs(1,:);
block_sizes = fs(2,:);
end_pos = start_pos+block_sizes;
adjusent = [false,start_pos(2:end)==end_pos(1:end-1)];
if any(adjusent)
    ic = 1;
    fs_new = zeros(2,numel(start_pos)-sum(adjusent));
    for i=1:numel(start_pos)
        if adjusent(i)
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
