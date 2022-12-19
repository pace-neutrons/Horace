function[obj,new_pos,compress_bat] = find_block_place_(obj, ...
    data_block_name,block_size)
% find place to put data block with name provided as input within the
% block positions, described by BAT.
%
% The block have to be already registered wit the BAT.
%
% Inputs:
% data_block_name
%            -- name of the block to find its place in the BAT
%               list
% block_size -- the size of block to place in BAT.
%Returns:
% obj        -- the BAT modified to accomodate new block
%               position
% new_pos    -- position to place block on hdd not to overlap
%               with other blocks
% compress_bat
%           -- if true, indicates that the blocks are placed on
%           hdd too loosely, so one needs to move then all
%           together to save space

nmb = ismember(obj.block_names_,data_block_name);
if ~any(nmb)
    error('HORACE:blockAllocationTable:invalud_argument', ...
        'The block with name %s is not registered in block allocation table', ...
        data_block_name);
end
bl_ind = find(nmb);
the_block = obj.block_list{bl_ind};
if block_size == the_block.size
    new_pos = the_block.position;
    compress_bat = false;
    return;
end
free_space_size = obj.free_space_pos_and_size_(2,:);

will_fit = free_space_size>=block_size;
if ~any(will_fit)
    fs = obj.free_space_pos_and_size_;
    new_pos = fs(1,end);

    all_free = sum(fs,2);
    all_free = all_free(2);
    compress_bat  = all_free>= block_size;

    % change last free space position to the new end of the file
    fs(1,end) = new_pos+block_size;
    % add the space freed after removing the current block to the list of
    % the free spaces
    fs = [fs,[the_block.position;the_block.size]];

    the_block.position = new_pos;
    the_block.size     = block_size;
else
    compress_bat = false;
    inds = find(will_fit);

    [~,finds] = min(free_space_size(inds));

end
[~,indx] = sort(fs,2);
fs = fs(:,indx);
obj.free_space_pos_and_size_ = fs;

obj.block_list{bl_ind} = the_block;