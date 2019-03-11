function [pixels,blocks_pos,pix_block_size]= read_pixels_matlab_(obj,blocks_pos,pix_block_size)
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
if numel(blocks_pos) == 1
    block_start = [blocks_pos-1,0];
    pix_chunk_size  = [pix_block_size,9];
    
    if obj.io_chunk_size_ ~= pix_block_size
        H5S.set_extent_simple(obj.io_mem_space_,2,pix_chunk_size,pix_chunk_size);
        obj.io_chunk_size_ = pix_block_size;
    end
    
    
    H5S.select_hyperslab(obj.file_space_id_,'H5S_SELECT_SET',block_start,[],[],pix_chunk_size);
    pixels=H5D.read(obj.pix_dataset_,'H5ML_DEFAULT',obj.io_mem_space_,obj.file_space_id_,'H5P_DEFAULT');
    
    blocks_pos = [];
else
    if numel(pix_block_size) ~=numel(blocks_pos)
        if numel(pix_block_size)==1
            npix = ones(numel(blocks_pos),1)*pix_block_size;
        else
            error('HDF_PIX_GROUP:invalid_argument',...
                'number of pix blocks (%d) has to be equal to the number of pix positions (%d) or be equal to 1',...
                numel(pix_block_size),numel(blocks_pos));
        end
    else
        if size(pix_block_size,2) ~=1
            npix = pix_block_size';
        else
            npix = pix_block_size;
        end
    end
    if size(blocks_pos,2) ~=1
        block_start = blocks_pos'-1;
    else
        block_start = blocks_pos-1;
    end
    
    n_blocks = numel(blocks_pos);
    block_start = [block_start,zeros(n_blocks,1)];
    pix_sizes = ones(n_blocks,1)*9;
    pix_chunk_size = [npix,pix_sizes];
    
    H5S.select_hyperslab(obj.file_space_id_,'H5S_SELECT_SET',block_start(1,:),[],[],pix_chunk_size(1,:));
    
    if npix(1)+npix(2) > obj.chunk_size_
        selected_size = npix(1);
        last_block2select = 1;
    else
        npix_tot = cumsum(npix);
        last_block2select = find(npix_tot > obj.chunk_size_,1)-1;
        if isempty(last_block2select)
            last_block2select=n_blocks;
            %elseif last_block2select == 1 this is covered by npix(1)+npix(2) > obj.chunk_size_
        end
        chunk_ind = 2:last_block2select;
        
        arrayfun(@(ind)H5S.select_hyperslab(obj.file_space_id_,'H5S_SELECT_OR',block_start(ind,:),[],[],pix_chunk_size(ind,:)),chunk_ind);
        selected_size = npix_tot(last_block2select);
    end
    
    %                 selected_size = pix_chunk_size(1,1);
    %                 n_blocks_selected = 1;
    %                 if selected_size < obj.cache_size
    %                     for i=2:n_blocks
    %                         next_size = selected_size+pix_chunk_size(i,1);
    %                         if selected_size>obj.chunk_size_
    %                             break;
    %                         end
    %                         selected_size = next_size;
    %                         H5S.select_hyperslab(obj.file_space_id_,'H5S_SELECT_OR',block_start(i,:),[],[],pix_chunk_size(i,:));
    %                         n_blocks_selected = n_blocks_selected +1;
    %                     end
    %                 end
    blocks_pos = blocks_pos(last_block2select+1:end);
    if numel(pix_block_size) > 1
        pix_block_size = pix_block_size(last_block2select+1:end);
    end
    
    mem_block_size = [selected_size,9];
    if obj.io_chunk_size_ ~= selected_size
        H5S.set_extent_simple(obj.io_mem_space_,2,mem_block_size,mem_block_size);
        obj.io_chunk_size_ = selected_size;
    end
    
    pixels=H5D.read(obj.pix_dataset_,'H5ML_DEFAULT',obj.io_mem_space_,obj.file_space_id_,'H5P_DEFAULT');
    
    
end

