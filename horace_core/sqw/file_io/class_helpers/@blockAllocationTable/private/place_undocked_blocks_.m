function obj = place_undocked_blocks_(obj,obj_to_write,nocache)
% replace contents of unlocked blocks with the contents of the
% input object and found places of these blocks within the BAT.
%
% Should work after clear_unlocked_blocks was called, as clear_unlocked_blocks
% calculates free spaces left after old blocks were removed.
%
% Inputs:
% obj           -- initialized instance of BAT.
% obj_to_write  -- input object, source of information about
%                  new block contents.
% nocache       -- logical variable, defining if serialized
%                  data from the obj_to_write should be cached
%                  within the data blocks for storing them
%                  later. If this variable is true, the
%                  serialized data used to calculate block size
%                  are ignored and recalated again when block
%                  is prepared for writing to disk. Takes longer
%                  but saves memory.
% Output:
% obj           -- modified instance of BAT, containing
%                  information on where to store modified
%                  object's blocks.

n_blocks = obj.n_blocks;
new_block_sizes = zeros(1,n_blocks);
unlocked = false(1,n_blocks );
for i=1:n_blocks
    block = obj.blocks_list_{i};
    if block.locked
        continue;
    end
    unlocked(i)  = true;
    block = block.calc_obj_size(obj_to_write,nocache,false);
    new_block_sizes(i) = block.size;
    obj.blocks_list_{i} = block;
end
block_sizes = new_block_sizes(unlocked);
%
% find where to place modified blocks.
[positions,free_spaces,eof_pos] = pack_blocks( ...
    obj.free_spaces_and_size_,block_sizes,obj.end_of_file_pos_);
%
obj.free_spaces_and_size_ = uint64(free_spaces);
obj.end_of_file_pos_      = uint64(eof_pos);
ic_changed = 0;
for i=1:n_blocks
    if ~unlocked(i)
        continue;
    end
    block = obj.blocks_list_{i};
    ic_changed = ic_changed+1;
    block.position = positions(ic_changed);
    obj.blocks_list_{i} = block;
end

