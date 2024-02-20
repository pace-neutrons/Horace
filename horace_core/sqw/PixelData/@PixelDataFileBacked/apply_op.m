function obj_out = apply_op(obj_in,page_op)
% Apply operation which changes pixels and image of an input sqw
% object in a way, not violating relation between pixel ordering and npix.
%
% Inputs:
% obj    --  PixelDataFilebacked object
% obj_in --  sqw or this PixeldData object which contains this pixel object
%            (if it contains other pixel object, that object will be
%            destroyed)
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

n_chunks = numel(npix_chunks);

% check if warning about data range is necessary.
issue_range_warning = page_op.do_missing_range_warning;
if issue_range_warning
    was_misaligned = false;
    is_range_valid = page_op.is_range_valid;
    if ~is_range_valid
        if isempty(page_op.outfile) && n_chunks>fbs && ll>0
            original_file  = obj_in.full_filename;
            was_misaligned = obj_in.pix.is_misaligned;
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
    lc = log_config();
    lc = lc.init_adaptive_logging();
end
%==========================================================================
% Run paging
for i=1:n_chunks % uses the fact that number of pixels must be equal to sum(npix)
    page_op = page_op.get_page_data(i,npix_chunks);
    page_op = page_op.apply_op(npix_chunks{i},npix_idx(:,i));
    page_op = page_op.common_page_op();
    % and each chunk after this split refers to mem_chunk_size pixels
    % located subsequently
    if ll > 0
        lc = print_progress_log(i,n_chunks,op_name,lc);
    end
end
obj_out = page_op.finish_op(obj_in);
%
if ll > 0
    [~,te] = lc.adapt_logging(n_chunks);
    fprintf('*** Completed %s using %d pages in %d sec.\n', ...
        op_name,n_chunks,te);
    if page_op.inform_about_target_file
        page_op.report_on_target_files(obj_out);
    end
end
if issue_range_warning
    old_file_format = ~was_misaligned;
    page_op.print_range_warning(original_file,old_file_format);
end

function log_control = print_progress_log(n_step,nsteps_total,op_name,log_control)
% function is called each loop iteration and prints progress report
% in the form:
% "."    -- per each loop iteration
% "number of steps passed"
%        -- after passing time interval defined in log_config class,
%           field info_log_print_time
% Inputs:
% n_step        -- number of current step to print log for
% nsteps_total  -- total number of steps the run will go
% op_name       -- name of page_op the loop runs
% log_control   -- instance lof log_config class, which defines when print
%                  progress report in more details (i.e.
%                  number_of_steps_passed)
fprintf('.')
[log_control,run_time] = log_control.adapt_logging(n_step);
log_split = log_control.info_log_split_ratio;
if mod(n_step, log_split) < eps('single')
    fprintf('.\n')
    fprintf('*** Finished %dof#%d chunks in %d sec performing %s\n', ...
        n_step,nsteps_total,run_time,op_name);
end
