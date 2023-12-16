function obj = clear_unlocked_blocks_(obj)
% method clears up information about position and sizes of all
% blocks which are not locked in their place updating information about
% free space which remains between the blocks which left
%

[bl_l,bl_space]  = cellfun(@clear_block,obj.blocks_list_,'UniformOutput',false);
obj.blocks_list_ = bl_l;
bl_space = cell2mat(bl_space);
bl_space = [bl_space,obj.free_space_pos_and_size_];
bl_space = merge_adjusent_space_(bl_space);
if bl_space(1,end)+bl_space(2,end) == obj.end_of_file_pos_
    obj.end_of_file_pos_ = bl_space(1,1);
end
if obj.end_of_file_pos_ == obj.blocks_start_position
    obj.initialized_ = false;
    obj.free_space_pos_and_size_ = zeros(2,0);
else
    obj.file_size_ = max(obj.file_size_,bl_space(1,end)+bl_space(2,end));
end


function [bl,bl_space] = clear_block(bl)
if bl.locked
    bl_space = zeros(2,0);
    return
end
bl_space = [bl.position;bl.size];
bl.position = 0;
bl.size = 0;


