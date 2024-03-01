function[obj,new_pos,compress_bat] = find_block_place_(obj, ...
    data_block_name_or_class,block_size)
% find place to put data block with name provided as input within the
% block positions, described by BAT.
%
% The block have to be already registered wit the BAT.
%
% Inputs:
% data_block_name_or_class
%            -- name of the block to find its place in the BAT
%               list or instance of data_block class defining its name
% block_size -- the size of block to place in BAT.
%Returns:
% obj        -- the BAT modified to accommodate new block
%               position
% new_pos    -- position to place block on hdd not to overlap
%               with other blocks
% compress_bat
%           -- if true, indicates that the blocks are placed on
%           hdd too loosely, so one needs to move then all
%           together to save space

[the_block,bl_ind] = obj.get_data_block(data_block_name_or_class);
if block_size == the_block.size && the_block.allocated
    new_pos = the_block.position;
    compress_bat = false;
    return;
end
if the_block.allocated
    % add the space freed after removing the current block to the list of
    % the free spaces
    old_block_place = [the_block.position;the_block.size];
    fs = [obj.free_spaces_and_size_,old_block_place];
    fs = merge_adjacent_space_(fs);
else
    fs = obj.free_spaces_and_size_;
end
free_space_size = fs(2,:);
will_fit = free_space_size>=block_size;

if ~any(will_fit)
    new_pos = obj.end_of_file_pos; % free space position was at the end but now we added just freed element to it

    all_free = sum(free_space_size);
    compress_bat  = all_free>= block_size;

    % change last free space position to the new end of the file
    obj.end_of_file_pos_ = new_pos+block_size;

    the_block.position = new_pos;
    the_block.size     = block_size;
else
    compress_bat = false;
    min_fit_size = min(free_space_size(will_fit));
    is_min_size = free_space_size==min_fit_size;
    %
    free_space_info = fs(:,is_min_size);
    new_pos        = free_space_info(1);
    the_block.position = new_pos;
    the_block.size     = block_size;

    if free_space_info(2) > block_size
        free_space_info(1) = new_pos+block_size;
        free_space_info(2) = free_space_info(2)-block_size;
        fs(:,is_min_size)=free_space_info;
    else  % efficiency can be greatly improved through proper container
        % here is very inefficient implementation, but the occasion is rare
        fs=fs(:,~is_min_size);
    end
end

if fs(1,end)+fs(2,end) == obj.end_of_file_pos
    obj.end_of_file_pos_ = fs(1,end);
    fs = fs(:,1:end-1);
end

obj.free_spaces_and_size_ = fs;
obj.blocks_list_{bl_ind} = the_block;

