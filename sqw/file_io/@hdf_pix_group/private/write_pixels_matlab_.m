function write_pixels_matlab_(obj,start_pos,pixels)


block_dims = [size(pixels,2),9];
if block_dims(1)<=0
    return;
end
if isa(pixels,'single')
    buff = pixels;
else
    buff = single(pixels);
end

if obj.io_chunk_size_ ~= block_dims(1)
    H5S.set_extent_simple(obj.io_mem_space_,2,block_dims,block_dims);
    obj.io_chunk_size_ = block_dims(1);
end

block_start = [start_pos-1,0];
if start_pos+block_dims(1)-1 > obj.max_num_pixels_
    error('HDF_PIX_GROUP:invalid_argument',...
        'The final position of pixels to write (%d) exceeds the allocated pixels storage (%d)',...
        start_pos+block_dims(1),obj.max_num_pixels_)
end

H5S.select_hyperslab(obj.file_space_id_,'H5S_SELECT_SET',block_start,[],[],block_dims);
H5D.write(obj.pix_dataset_,'H5ML_DEFAULT',obj.io_mem_space_,obj.file_space_id_,'H5P_DEFAULT',buff);

