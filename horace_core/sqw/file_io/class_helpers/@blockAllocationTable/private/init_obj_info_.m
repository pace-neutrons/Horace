function obj = init_obj_info_(obj,obj_to_analyze,nocache,insertion)
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
% insertion -- if true, calculate the size only for objects, which do not
%                   have their size calculated and find location of other
%                   blocks between already allocated spaces.
%
% Result:
% The blocks defined in this BlockAllocationTable calculate
% their sizes and their positions are calculated assuming that
% they are placed one after another without gaps.
%
n_b = obj.n_blocks;
block_size = zeros(n_b,1);
if insertion
    preallocated = false(1,n_b);
end
for i=1:n_b
    db = obj.blocks_list_{i};
    if insertion
        if db.position > 0 % block size and position are already calculated
            % just check them
            preallocated(i) = true;
            db_check = db.calc_obj_size(obj_to_analyze,true);
            if db_check.size ~=db.size
                error('HORACE:blockAllocationTable:runtime_error', ...
                    'Size of the pre-allocated block (%d) is different from the size of the same block calculated now (%d)', ...
                    db.size,db_check.size);
            end
        end
    end
    db = db.calc_obj_size(obj_to_analyze,nocache);
    block_size(i) = db.size;

    obj.blocks_list_{i} = db;
end
if insertion
    for i=1:n_b
        if preallocated(i);   continue;
        end
        db = obj.blocks_list_{i};
        obj = obj.find_block_place(db,block_size(i));
    end
else
    block_pos = uint64(cumsum(block_size));
    block_pos = [uint64(0);block_pos]+obj.blocks_start_position;
    for i=1:n_b
        obj.blocks_list_{i}.position = block_pos(i);
    end
end
obj.end_of_file_pos_  = block_pos(end);
obj.initialized_ = true;
