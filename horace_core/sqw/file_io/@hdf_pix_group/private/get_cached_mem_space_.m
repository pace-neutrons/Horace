function mem_space_id = get_cached_mem_space_(obj,block_dims)
% function extracts hdf memory space object information from
% the properly initialized memory space object
if obj.io_chunk_size_ ~= block_dims(1)
    H5S.set_extent_simple(obj.io_mem_space_,2,block_dims,block_dims);
    obj.io_chunk_size_ = block_dims(1);
end
mem_space_id = obj.io_mem_space_;

