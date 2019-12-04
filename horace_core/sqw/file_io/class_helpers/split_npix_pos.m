function [pos,npix,pos_remain,npix_remain,buf_size] = split_npix_pos(blocks_pos,pix_block_size,buf_size,n_parts)
% Divide the information, about pixels to read among selected number of
% chunks
%
% The routine is the part of cut operator and is used to make cut in
% parallel. It is also used to help reading a specified number of pixels
% from the whole number of pixels specified as the pixels range.
%
%
% Usage:
% [pos,npix,pos_remain,npix_remain] = split_npix_pos(blocks_pos,pix_block_size,buf_size,n_parts)
% Where:
%blocks_pos     -- the array of the pixel block positions in the array of
%                  the pixels.
%pix_block_size -- the array of the pixel block sizes in the pixels array.
%buf_size       -- number of pixels in a single chunk of data. If empty,
%                  calculated as number of pixels per part. If not, divides
%                  the total number of pixels in two parts, where the size
%                  of the first one equal to buf_size, and the
%                  second contains everything larger than this number
%n_parts        -- number of parts to divide input data in.
% Outputs:
% pos -- cellarray of size [nparts x 1] or array (if n_parts == 1) of pixels
%        positions for the pixels fitting buf_size
% npix -- cellarray of size [nparts x 1] or array (if n_parts == 1) of pixels blocks
%         sizes fiting the buf_size
% pos_remain --the array of pixels positions, exceeding buf_size*n_parts
% npix_remain--the array of pixels block sizes, exceeding buf_size*n_parts
% buf_size  -- the size of the buffer modified to fit whole blocks of
%              pixels
%
%WARNING!:
% The block_positions must be sorted and satisfy the unequality:
% block_pos(i)+pix_block_size(i) < block_pos(i+1). This is not verified for
% efficiency but assumed everywhere.
%

% the ratio to increase buffer size to fit whole number of pixels blocks
fiddle_range = 1.1;

if ~exist('n_parts','var') || n_parts<1
    n_parts = 1;
end

cum_sizes = cumsum(pix_block_size);
n_pixels_tot = cum_sizes(end);
if ~exist('buf_size','var') || isempty(buf_size)
    buf_size = n_pixels_tot ;
end

if n_pixels_tot <= buf_size && n_parts == 1
    pos = blocks_pos;
    npix = pix_block_size;
    buf_size = n_pixels_tot;
    pos_remain = [];
    npix_remain = [];
    return;
end

chunk_size = floor(buf_size/n_parts);
chunk_sizes = ones(1,n_parts)*chunk_size;
block = chunk_size*n_parts;
if block < buf_size
    i=1;
    while block<buf_size
        chunk_sizes(i)=chunk_sizes(i)+1;
        block = block+1;
    end
end
if n_parts == 1
    [pos,npix,~,pos_remain,npix_remain,buf_size] = ...
        split_range(cum_sizes,blocks_pos,pix_block_size,buf_size,fiddle_range);
else
    pos = cell(1,n_parts);
    npix = cell(1,n_parts);
    buf_size = 0;
    for i=1:n_parts
        [pos{i},npix{i},cum_sizes,blocks_pos,pix_block_size,block_size] = ...
            split_range(cum_sizes,blocks_pos,pix_block_size,chunk_sizes(i),fiddle_range);
        buf_size = buf_size +block_size;
    end
end

function [pos,npix,cum_sizes,pos_remain,npix_remain,buf_size]=...
    split_range(cum_sizes,blocks_pos,block_size,buf_size,fiddle_range)

fits = (cum_sizes <=buf_size);
last_fit_ind = find(fits,1);
if isempty(last_fit_ind)
    pos = blocks_pos(1);
    if (block_size(1)<=buf_size*fiddle_range)
        buf_size = block_size(1);
        
        cum_sizes = cum_sizes-buf_size;
        cum_sizes = cum_sizes(2:end);
        pos_remain= blocks_pos(2:end);
        npix_remain=block_size(2:end);
    else
        cum_sizes     = cum_sizes-buf_size;
        pos_remain    = blocks_pos;
        npix_remain   = block_size;
        pos_remain(1) = blocks_pos(1)+buf_size;
        npix_remain(1)= npix_remain(1)-buf_size;
    end
    npix = buf_size;
elseif last_fit_ind==numel(blocks_pos)
    pos = blocks_pos;
    npix = block_size;
    cum_sizes = [];
    pos_remain = [];
    npix_remain = [];
else
    lfi1 = last_fit_ind+1;
    if cum_sizes(lfi1)<=buf_size*fiddle_range
        buf_size = cum_sizes(lfi1);
        fits(lfi1)=true;
        pos_remain = blocks_pos(~fits);
        npix_remain = block_size(~fits);
        pos  = blocks_pos(fits);
        npix = block_size(fits);
    else
        pos_remain = blocks_pos(~fits);
        npix_remain = block_size(~fits);
        % number of pixels from last block which do not fit the buffer   
        delta = cum_sizes(lfi1)-buf_size;
        cum_sizes = cum_sizes(~fits)-buf_size;                
        
        fits(lfi1)=true;
        pos  = blocks_pos(fits);
        npix = block_size(fits);
        npix(end) =  block_size(lfi1)-delta;
        pos_remain(1) = blocks_pos(lfi1)+npix(end);
        npix_remain(1) = delta;

    
    end
end
