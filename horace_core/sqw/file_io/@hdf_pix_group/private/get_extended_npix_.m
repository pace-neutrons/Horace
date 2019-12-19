function npix = get_extended_npix_(n_pixels,chunk_size)
% get number of pixels proportional to a chunk size.
n_blocks = n_pixels/chunk_size ;
if rem(n_pixels,chunk_size)>0
    n_blocks = floor(n_blocks) +1;
    
end
npix = chunk_size*n_blocks;
