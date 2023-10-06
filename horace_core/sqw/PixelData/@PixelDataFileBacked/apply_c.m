function sqw_out = apply_c(sqw_in,page_op)
% Apply operation which changes pixels and image of an input sqw
% object in a way, not violating relation between pixel ordering and npix.
%
% Inputs:
% obj    --  PixelDataFilebacked object
% sqw_in --  sqw object which contains this pixel object (if it contains
%            other pixel object, that object will be destroyed
%            Valid sqw  object requested, i.e. obj.data.npix define the
%            location of pixels in file
%page_op --  The instance of the PageOpBase class, which perform operation
%            over pixels and image of the SQW object
% Output:
% sqw_out -- sqw_in object, modified using the operation provided as input
%
if isa(sqw_in,'sqw')
    npix = sqw_in.data.npix(:);
else
    npix = page_op.npix;
end
[mem_chunk_size,ll] = config_store.instance().get_value('hor_config', 'mem_chunk_size','log_level');
[npix_chunks, npix_idx] = split_vector_max_sum(npix, mem_chunk_size);
log_split = page_op.log_split_ratio;

n_chunks = numel(npix_chunks);
pix_idx_1= 1;
for i=1:n_chunks
    npix = sum(npix_chunks{i});
    pix_idx_2 = pix_idx_1+npix-1;
    if ll > 0 && mod(i, log_split) == 1
        fprintf('Processing page: %d/%d\n', i, n_chunks);
    end

    [page_op,page_data] = page_op.apply_op(npix_chunks{i},npix_idx(:,i),pix_idx_1,pix_idx_2);
    page_op = page_op.common_page_op(page_data);
    pix_idx_1 = pix_idx_2+1;
end
sqw_out = page_op.finish_op(sqw_in);
if ll > 0
    fprintf('finished processing : %d Pages\n', n_chunks);
end

