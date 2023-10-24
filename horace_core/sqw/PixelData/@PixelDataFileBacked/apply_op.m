function sqw_out = apply_op(sqw_in,page_op)
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

[mem_chunk_size,ll,fbs] = config_store.instance().get_value( ...
    'hor_config', 'mem_chunk_size','log_level','fb_scale_factor');

% divide all data into pages to process
[npix_chunks, npix_idx,page_op] = page_op.split_into_pages(npix, mem_chunk_size);

log_split = page_op.split_log_ratio;

n_chunks = numel(npix_chunks);

% check if warning about data range is necessary.
issue_range_warning = page_op.do_missing_range_warning;
if issue_range_warning
    was_misaligned = false;
    is_range_valid = page_op.is_range_valid;
    if ~is_range_valid
        if isempty(page_op.outfile) && n_chunks>fbs && ll>0
            original_file  = sqw_in.full_filename;
            was_misaligned = sqw_in.pix.is_misaligned;
            issue_range_warning = true;
        else
            issue_range_warning = false;
        end
    else
        issue_range_warning = false;
    end
end
%
if ll>0
    t0 = tic;
end
%==========================================================================
% Run paging
for i=1:n_chunks % uses the fact that number of pixels must be equal to sum(npix)
    page_op = page_op.get_page_data(i,npix_chunks);
    page_op = page_op.apply_op(npix_chunks{i},npix_idx(:,i));
    page_op = page_op.common_page_op();
    % and each chunk after this split refers to mem_chunk_size pixels
    % located subsequently
    if ll > 0 && mod(i, log_split) == 1
        tc = toc(t0);
        fprintf('*** Finished %dof#%d chunks in %d sec performing %s\n', ...
            i,n_chunks,tc,op_name);
    end

end
sqw_out = page_op.finish_op(sqw_in);
%
if ll > 0
    te = toc(t0);
    fprintf(['*** Completed %s using %d pages in %d sec.\n' ...
        '*** Resulting object is backed by file: %s\n'], ...
        op_name,n_chunks,te,sqw_out.full_filename);
end
if issue_range_warning
    old_file_format = ~was_misaligned;
    page_op.print_range_warning(original_file,old_file_format);
end
