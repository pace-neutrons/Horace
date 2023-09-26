function  obj = set_data_block_(obj,block_instance)
% set data block with defined position and size in the free
% space defined by current block allocation table.
%
% Input:
% block_instance: The instance of data_block already present in
%                BAT, with new position and size defined in the
%                block_instance
%
% Returns:
% modified BAT, containing new block at the position specified
% in input and free spaces list modified according to the
% changes, caused by placing the block in the specified
% position.
%
% Throws if the input block location overlaps with locations of
% any existing blocks

% find place of the block_instance in the current blocks subscription list
%
targ_name = block_instance.block_name;
targ_start  = block_instance.position;
targ_size = block_instance.size;
[initialized,targ_found,start_position,size] = cellfun(@(x)block_info(x,targ_name), ...
    obj.blocks_list_);

if ~any(targ_found)
    error('HORACE:blockAllocatinTable:invalid_argument', ...
        'Block with name %s is not described in the blockAllocationTable', ...
        targ_name)
end
if targ_start<obj.blocks_start_position
    error('HORACE:blockAllocatinTable:invalid_argument', ...
        'Block: %s requested position overlaps with location of BAT',targ_name);
end
%
initialized    = initialized(~targ_found);
start_position = start_position(~targ_found);
size           = size(~targ_found);
%
first_pos = start_position(initialized);
next_pos   = first_pos + size(initialized);
targ_end   = targ_start+targ_size-1;
%
overlap = (targ_start >= first_pos & targ_start < next_pos) | (targ_end >= first_pos & targ_end <  next_pos);
if any(overlap)
    error('HORACE:blockAllocatinTable:invalid_argument', ...
        'Block %s location overlaps with location of existing blocks %s', ...
        targ_name, disp2str(obj.block_names(overlap)))
end
% find free spaces between blocks
obj.blocks_list_{targ_found} = block_instance;
obj.end_of_file_pos_ = max(obj.end_of_file_pos_,block_instance.position+block_instance.size);
first_pos  = [0,first_pos,targ_start];
next_pos   = [obj.blocks_start_position,next_pos,targ_end+1];
[first_pos,s_ind] = sort(first_pos);
next_pos          = next_pos(s_ind);
%
free_spaces = first_pos(2:end)-next_pos(1:end-1)-1;
valid = free_spaces>0;
obj.free_space_pos_and_size_ = [next_pos([valid,false]);free_spaces(valid)];


function [is_init,is_requested,position,size]=block_info(other_block,targ_block_name)
% retrieve statistical parameters of the block
position = other_block.position;
size     = other_block.size;
is_init  = other_block.allocated;
is_requested = strcmp(other_block.block_name,targ_block_name);
