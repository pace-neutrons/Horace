function sqw_out = apply_c(sqw_in,page_op)
% Apply operation which changes pixels and image of an input sqw
% object in a way, not violating relation between pixel ordering and npix.
%
% Inputs:
% obj    --  PixelDataFilebacked object
% sqw_in --  sqw object which contains this pixel object (if it contains
%            other pixel object, that object will be destroyed
%            Valid sqw  object requested, i.e. obj.data.npix define the
%            location of pixels in file and in memory.
%
%page_op --  The instance of the PageOpBase class, which perform operation
%            over pixels and image of the SQW object
% Output:
% sqw_out -- sqw_in object, modified using the operation provided as input
%
npix = page_op.npix;
op_name = page_op.op_name;

[mem_chunk_size,ll] = config_store.instance().get_value('hor_config', 'mem_chunk_size','log_level');
% divide all data into pages to process
[npix_chunks, npix_idx] = page_op.split_into_pages(npix, mem_chunk_size);

log_split = page_op.split_log_ratio;

n_chunks = numel(npix_chunks);
for i=1:n_chunks % uses the fact that number of pixels must be equal to sum(npix)
    % and each chunk after this split refers to mem_chunk_size pixels
    % located subsequently
    page_op.page_num = i;
    if ll > 0 && mod(i, log_split) == 1
        fprintf('*** Performing %s on page: %d/%d\n',op_name, i, n_chunks);
    end
    page_op = page_op.apply_op(npix_chunks{i},npix_idx(:,i));
    page_op = page_op.common_page_op();
end
sqw_out = page_op.finish_op(sqw_in);
if ll > 0
    fprintf('*** Finished %s on object backed by file: %s using %d pages\n', ...
        op_name,sqw_out.data.filename,n_chunks);
end

