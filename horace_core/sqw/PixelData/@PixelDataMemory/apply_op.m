function obj_out = apply_op(obj_in,page_op)
% Apply operation which changes pixels and image of an input sqw
% object in a way, not violating relation between pixel ordering and npix.
%
%
% Inputs:
% obj    --  PixelDataMemory object
% obj_in --  sqw object which contains this pixel object (if it contains
%            other pixel object, that object will be destroyed.
%            Valid sqw  object requested, i.e. obj.data.npix define the
%            location of pixels in memory
%  Or
%            PixelData object to operate on
%page_op --  The instance of the PageOpBase class, which perform operation
%            over pixels and image of the SQW object
% Output:
% sqw_out -- sqw_in object, modified using the operation provided as input
%

npix = page_op.npix;
% use chunk size equal to total number of pixels to split pixels into one
% chunk. Allows to overload split_into_pages for some specific operations
mem_chunk_size = sum(npix);
[npix_chunks, npix_idx,page_op] = page_op.split_into_pages(npix, mem_chunk_size);

page_op = page_op.get_page_data(1,npix_chunks);
page_op = page_op.apply_op(npix,npix_idx);
page_op = page_op.common_page_op();
%
obj_out = page_op.finish_op(obj_in);