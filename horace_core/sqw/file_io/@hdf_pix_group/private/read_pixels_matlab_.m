function pixels= read_pixels_matlab_(obj,blocks_pos,pix_block_size)
% read pixel information specified by pixels starting position
% and the sizes of the pixels blocks
%
%Inputs:
%blocks_pos     -- array of pixel blocks positions to read
%pix_block_size -- array of block sizes to read
%
%Outputs:
%pixels     [9 x npix] array of pixels information
%blocks_pos            array of pixel blocks positions which
%                      have not been read in current read
%                      operation. Empty if all pixels defined
%                      by the input arrays have been read.
%pix_block_size        array of pixel block sizes, have not
%                      been read by current read operation
%
% n_pix always > 0 and numel(start_pos)== numel(n_pix) (or n_pix == 1)
% for algorithm to be correct
block_start = [blocks_pos(1)-1,0];
pix_chunk_size  = [pix_block_size(1),9];

if obj.io_chunk_size_ ~= pix_block_size(1)
    H5S.set_extent_simple(obj.io_mem_space_,2,pix_chunk_size,pix_chunk_size);
    obj.io_chunk_size_ = pix_block_size(1);
end
H5S.select_hyperslab(obj.file_space_id_,'H5S_SELECT_SET',block_start,[],[],pix_chunk_size);
pixels=H5D.read(obj.pix_dataset_,'H5ML_DEFAULT',obj.io_mem_space_,obj.file_space_id_,'H5P_DEFAULT');
if numel(blocks_pos) == 1
    return;
else
    sub_pix = cell(1,numel(blocks_pos));
    sub_pix{1} = pixels;
end

for i=2:numel(blocks_pos)
    block_start = [blocks_pos(i)-1,0];
    pix_chunk_size  = [pix_block_size(i),9];
    if obj.io_chunk_size_ ~= pix_block_size(i)
        H5S.set_extent_simple(obj.io_mem_space_,2,pix_chunk_size,pix_chunk_size);
        obj.io_chunk_size_ = pix_block_size(i);
    end
    H5S.select_hyperslab(obj.file_space_id_,'H5S_SELECT_SET',block_start,[],[],pix_chunk_size);
    sub_pix{i}=H5D.read(obj.pix_dataset_,'H5ML_DEFAULT',obj.io_mem_space_,obj.file_space_id_,'H5P_DEFAULT');
end
pixels = [sub_pix{:}];

