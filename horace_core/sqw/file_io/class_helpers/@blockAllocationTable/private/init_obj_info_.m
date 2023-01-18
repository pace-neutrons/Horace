function obj = init_obj_info_(obj,obj_to_analyze,nocache)
% Initialize block allocation table for the object, provided as
% input.
% Inputs:
% obj_to_analyze -- the object to split into sub-blocks and
%                   create BAT for. The object has to be
%                   compatible with the data_block-s list,
%                   provided at construction of the BAT.
% nocache  -- if true, cache serialized
%                   binary representation of obj_to_analyze
%                   while calculating sizes of its blocks.
%             if false, the binary representation will be
%                   recalculated when the object will be
%                   written on hdd, and method will just
%                   calculate sizes and future locations
%                   of the blocks.
% Result:
% The blocks defined in this BlockAllocationTable calculate
% their sizes and their positions are calculated assuming that
% they are placed one after another without gaps.
%
n_b = obj.n_blocks;
block_size = zeros(n_b,1);
for i=1:n_b
    db = obj.blocks_list_{i};
    db = db.calc_obj_size(obj_to_analyze,nocache);
    block_size(i) = db.size;
    obj.blocks_list_{i} = db;
end
block_pos = uint64(cumsum(block_size));
block_pos = [uint64(0);block_pos]+obj.blocks_start_position;
for i=1:n_b
    obj.blocks_list_{i}.position = block_pos(i);
end
obj.end_of_file_pos_  = block_pos(end);
obj.initialized_ = true;
