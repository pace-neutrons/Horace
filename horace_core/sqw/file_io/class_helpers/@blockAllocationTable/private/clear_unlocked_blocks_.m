function obj = clear_unlocked_blocks_(obj)
% method clears up information about position and sizes of all
% blocks which are not locked in their place updating information about
% free space which remains between the blocks which remain locked.
%

[bl_l,bl_space]  = cellfun(@clear_block,obj.blocks_list_,'UniformOutput',false);
obj.blocks_list_ = bl_l;
bl_space = cell2mat(bl_space);
bl_space = [bl_space,obj.free_spaces_and_size_];
bl_space = merge_adjusent_space_(bl_space);
if bl_space(1,end)+bl_space(2,end) == obj.end_of_file_pos_
    % some free space found at the end of the file. Move end of the file.
    obj.end_of_file_pos_ = bl_space(1,end);
    bl_space = bl_space(:,1:end-1);    
end
if obj.end_of_file_pos_ == obj.blocks_start_position
    % all space is free, no blocks remain, but uninitialized
    obj.initialized_      = false;
end
obj.free_spaces_and_size_ = uint64(bl_space);


function [bl,bl_space] = clear_block(bl)
if bl.locked
    bl_space = uint64(zeros(2,0));
    return
end
bl_space = [bl.position;bl.size];
bl.position = 0;
bl.size = 0;


