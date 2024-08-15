function [s, e, npix, pix_out, unique_runid] = ...
    cut_accumulate_data_(obj, targ_proj, targ_axes, keep_pixels, log_level, sym)
%%CUT_ACCUMULATE_DATA Accumulate image and pixel data for a cut
%
% Input:
% ------
% targ_proj  A 'projection' object, defining the projection of the cut.
% targ_axes  A 'AxesBlockBase' object defining the ranges, binning and geometry
%            of the target cut
% keep_pixels A Boolean defining whether pixel data should be retained. If this
%            is false return variable 'pix_out' will be empty.
% log_level  The verbosity of the log messages. The values correspond to those
%            used in 'hor_config', see `help hor_config/log_level`.
%
% Output:
% -------
% s            The image signal data.
% e            The variance in the image signal data.
% npix         Array defining how many pixels are contained in each image
%              bin. size(npix) == size(s)
% pix_out      A PixelData object containing pixels that contribute to the
%              cut or Temp file manager/combiner class instance for performing
%              out-of-memory cuts. Contains information on pixels to be
%              combined together if cut_to_file is selected for the cuts,
%              which do not fit memory
% unique_runid Array of pixel run indexes, contributed to the cut. used to
%              retain only experiments, which indeed contributed to the
%              cut.
%
% CALLED BY cut_single
%


% Pre-allocate image data
sz1 = targ_axes(1).dims_as_ssize();
% note that 1D allocator of size N returns NxN array while we need Nx1
% array
%nbin_as_size = get_nbin_as_size(sz1);
s = zeros(sz1);
e = zeros(sz1);
npix = zeros(sz1);

% Get bins that may contain pixels that contribute to the cut.
% The bins selected are those that sit within (or intersect) the bounds of the
% cut. See the relevant projection function for more details.

sproj = obj.data.proj;
saxes = obj.data.axes;

if numel(obj.data.npix) == 1 % single bin original grid
    block_starts = 1;
    block_sizes = obj.data.npix;
else
    [block_starts, block_sizes] = arrayfun(@(proj, ax) sproj.get_nrange(obj.data.npix, saxes, ax, proj), ...
        targ_proj, targ_axes, 'UniformOutput', false);
    [block_starts, block_sizes] = merge_ranges(block_starts, block_sizes);
end

if isempty(block_starts)
    report_cut_type(obj, log_level-1, false, keep_pixels);

    % No pixels in range, we can return early
    pix_out = PixelDataBase.create();
    unique_runid = [];
    return
end

n_candidate_pix = sum(block_sizes);

large_pixels = PixelDataBase.do_filebacked(n_candidate_pix) && keep_pixels;
cut_to_file = ~return_cut || large_pixels;
% Always cut in mem if not in file, leave as debugging option to compare with filebacked ops.
cut_in_mem = ~cut_to_file;

fb_scale = config_store.instance().get_value('hor_config','fb_scale_factor');
if cut_in_mem && PixelDataBase.do_filebacked(n_candidate_pix, fb_scale) && keep_pixels
    warning('HORACE:cut:large_cut', ['Requested cut may retain up to %d pixel indices, which may exceed system memory\n', ...
        'Suggested fix: use cut with ''-save''\n', ...
        'Recommended limit: b_scale_factor*mem_chunk_size (%d) specified in hor_config'], ...
        n_candidate_pix,fb_scale*get(hor_config, 'mem_chunk_size'));
end

if keep_pixels
    [npix, s, e, pix_out, unique_runid] = cut_with_pixels(obj.pix, block_starts, block_sizes, targ_proj, ...
        targ_axes, npix, s, e, log_level,keep_precision, pixel_contrib_name, sym);
else
    [npix, s, e, pix_out, unique_runid] = cut_no_pixels(obj.pix, block_starts, block_sizes, targ_proj, ...
        targ_axes, npix, s, e, log_level, pixel_contrib_name);
end
[s, e] = normalize_signal(s, e, npix);

end  % function

function [npix, s, e, pix_out, unique_runid] = cut_no_pixels(pix, block_starts, block_sizes, ...
    targ_proj, targ_axes, npix, s, e, ll, ...
    pixel_contrib_name)

hc = hor_config;
chunk_size = hc.mem_chunk_size;
% Get indices in order to split the candidate bin ranges into chunks whose sums
% are less than, or equal to, a pixel page size
block_chunks = split_data_blocks(block_starts, block_sizes, chunk_size);
num_chunks = numel(block_chunks);
npix_tot_retained = 0;

if ll>=2
    n_read_pixels = 0;
    n_retained_pixels = 0;
    pix_byte_size   = pix.get_pix_byte_size(true);
    time_to_read    = zeros(num_chunks,1);
    time_to_process = zeros(num_chunks,1);
    t_proj_start = tic;
end

for iter = 1:num_chunks
    % Get pixels that will likely contribute to the cut
    chunk = block_chunks{iter};
    pix_start = chunk{1};
    block_sizes = chunk{2};

    if ll>=2
        tic;
    end

    candidate_pix = pix.get_pix_in_ranges(pix_start, block_sizes, false, true);

        if ll >= 1
        if ll>=2
            n_read_pixels = n_read_pixels + candidate_pix.num_pixels;
            time_to_read(iter)= toc;
            tic;
        end
        fprintf('*** Step %d of %d; Read data for %8d pixels -- processing data...', ...
            iter, num_chunks, candidate_pix.num_pixels);
    end

    if isscalar(targ_proj)
        [npix, s, e] = targ_proj.bin_pixels(targ_axes, candidate_pix, npix, s, e);
    else
        for i = 1:numel(targ_proj)
            [npix, s, e, selected] = targ_proj(i).bin_pixels(targ_axes(i), candidate_pix, npix, s, e, '-return_selected');
            candidate_pix = candidate_pix.tag(selected);
        end
    end

    if ll >= 1
        npsr = sum(npix(:));
        npix_step_retained = npsr - npix_tot_retained;
        npix_tot_retained = npsr;
        if ll>=2
            time_to_process(iter) = toc;
            n_retained_pixels     = n_retained_pixels+npix_step_retained;
            tic;
    end
        fprintf(' ----->  %s  %8d pixels\n', pixel_contrib_name, npix_step_retained);
    end

end  % loop over pixel blocks

pix_out = PixelDataBase.create();
unique_runid = [];
if ll>=2
    total_proj_time = toc(t_proj_start);
    data_proc_time  = sum(time_to_process);
    pix_read_time   = sum(time_to_read);

    log_progress(pix.is_filebacked,pix_byte_size, ...
        pix.num_pixels,n_read_pixels,n_retained_pixels, ...
        total_proj_time,pix_read_time,data_proc_time,0);
end


end

function [npix, s, e, pix_out, unique_runid] = cut_with_pixels(pix, block_starts, block_sizes, ...
    targ_proj, targ_axes, npix, s, e, ll, ...
    keep_precision, pixel_contrib_name, sym)

hc = hor_config;
chunk_size = hc.mem_chunk_size;
fb_size    = hc.fb_scale_factor;
buf_size   = chunk_size*fb_size;

% Get indices in order to split the candidate bin ranges into chunks whose sums
% are less than, or equal to, a pixel page size
block_chunks = split_data_blocks(block_starts, block_sizes, chunk_size);
num_chunks = numel(block_chunks);
num_proj = numel(targ_proj);

% Create a pix_comb_info object to handle tmp files of pixels
num_bins = numel(s);
pix_comb_info = init_pix_combine_info(num_chunks*num_proj, num_bins);
clearPixAccum = onCleanup(@() cut_data_from_file_job.accumulate_pix('cleanup'));

unique_runid = [];
if ll>=2
    n_read_pixels = 0;
    n_retained_pixels = 0;
    pix_byte_size   = pix.get_pix_byte_size(true);
    time_to_read    = zeros(num_chunks,1);
    time_to_process = zeros(num_chunks,1);
    time_to_accum   = zeros(num_chunks,1);
    t_proj_start = tic;
end

for iter = 1:num_chunks
    % Get pixels that will likely contribute to the cut
    chunk = block_chunks{iter};
    pix_start = chunk{1};
    block_sizes = chunk{2};
    if ll>=2
        tic;
    end

    candidate_pix = pix.get_pix_in_ranges(pix_start, block_sizes, false, keep_precision);
    if ll >= 1
        if ll>=2
            n_read_pixels = n_read_pixels + candidate_pix.num_pixels;
            time_to_read(iter)= toc;
            tic;
        end
        fprintf('*** Step %d of %d; Read data for %8d pixels -- processing data...', ...
            iter, num_chunks, candidate_pix.num_pixels);
    end

    for i = 1:num_proj

        % Pix not sorted here
        [npix, s, e, pix_ok, unique_runid_l, pix_indx, selected] = ...
            targ_proj(i).bin_pixels(targ_axes(i), candidate_pix, npix, s, e);

        candidate_pix = sym{i}.transform_pix(candidate_pix, {}, selected);
        candidate_pix = candidate_pix.tag(selected);

        npix_step_retained = pix_ok.num_pixels; % just for logging the progress
        unique_runid = unique([unique_runid, unique_runid_l(:)']);

        if ll >= 1
            if ll>=2
                time_to_process(iter) = toc;
                n_retained_pixels     = n_retained_pixels+npix_step_retained;
                tic;
        end
            fprintf(' ----->  %s  %8d pixels\n', pixel_contrib_name, npix_step_retained);
        end

        % Store produced data in cache, and when the cache is full
        % generate tmp files. Return pixfile_combine_info object to manage
        % the files - this object then used to recombine the files within
        % PageOp_sqw_join operation.
        pix_comb_info = cut_data_from_file_job.accumulate_pix(pix_comb_info, false, ...
            pix_ok, pix_indx, npix, ...
            buf_size,ll);
        if ll>=2
            time_to_accum(iter) = toc;
            tic;
    end
    end
end  % loop over pixel blocks

% store partial pixel_blocks remaining memory to tmp files if some files
% were written or collect together data stored in memory.
% return pix_out which is either pixfile_combine_info or PixelDataMemory
% depending on how many pixels were extracted.
pix_out = cut_data_from_file_job.accumulate_pix(pix_comb_info, true,[],[],npix);
if ll>=2
    accum_time = toc;
    total_proj_time = toc(t_proj_start);
    data_proc_time  = sum(time_to_process);
    pix_read_time   = sum(time_to_read);
    pix_accum_time  = accum_time +sum(time_to_accum);

    log_progress(pix.is_filebacked,pix_byte_size, ...
        pix.num_pixels,n_read_pixels,n_retained_pixels, ...
        total_proj_time,pix_read_time,data_proc_time,pix_accum_time);
end
end

function pci = init_pix_combine_info(nfiles, nbins)
% Create a pixfile_combine_info object to manage temporary files of pixels
wk_dir = get(parallel_config, 'working_directory');
tmp_file_names = gen_unique_file_paths(nfiles, 'horace_cut', wk_dir);
pci = pixfile_combine_info(tmp_file_names, nbins);

end

function pixel_contrib_name = report_cut_type(obj, log_level, use_tmp_files, keep_pixels)
% Routine prints the information about the cut type and how it would be
% done to inform user about the intended cut and expected results.
%
% in some situations report that no data contribute to the cut and the cut
% is not performed.
%
if isa(obj, 'sqw')
    if obj.pix.is_filebacked
        obj_type = 'file-backed';
    else
        obj_type = 'in memory';
    end
else
    obj_type = 'in file';
end

if use_tmp_files
    target = 'in file';
else
    target = 'in memory';
end

if keep_pixels
    pix_state = 'kept';
    pixel_contrib_name = 'retained';
else
    pix_state = 'dropped';
    pixel_contrib_name ='included';
end

if log_level > 1
    if use_tmp_files && ~keep_pixels
        fprintf('*** Cutting %s sqw object; returning result %s --> ignored as cut contains no pixels\n', ...
            obj_type, target);
    elseif ~keep_pixels
        fprintf('*** Cutting %s sqw object; returning result %s; No resulting pixels requested\n', ...
            obj_type, target);
    else
        fprintf('*** Cutting %s sqw object; returning result %s; retuning pixels - %s\n', ...
            obj_type, target, pix_state);
    end
end
end

function log_progress(is_filebacked,pix_byte_size,npix_total,n_read_pixels,n_retained_pixels, ...
    total_proj_time,pix_read_time,data_proc_time,pix_accum_time)

disp('--------------------------------------------------------------------------------')
if is_filebacked
    fprintf('Number of points in input file: %d\n',npix_total);
    fprintf('         Fraction of file read: %8.2f%% (=%10d points) ;  Read speed: %8.2fMB/sec\n',...
        100*n_read_pixels/double(npix_total),n_read_pixels,n_read_pixels*pix_byte_size/(1024*1024)/pix_read_time);
    fprintf('     Fraction of file retained: %8.2f%% (=%10d points)\n',...
        100*n_retained_pixels/double(npix_total),n_retained_pixels);
else
    fprintf('Number of points in input object: %d\n',npix_total);
    fprintf('     Fraction of object selected: %8.2f%% (=%10d points) ;  Access speed: %8.2fGB/sec\n',...
        100*n_read_pixels/double(npix_total),n_read_pixels,n_read_pixels*pix_byte_size/(1024*1024*1024)/pix_read_time);
    fprintf('     Fraction of object retained: %8.2f%% (=%10d points)\n',...
        100*n_retained_pixels/double(npix_total),n_retained_pixels);
end

disp(' ')
fprintf([...
    '**** Total time in cut(sqw)   : %8.1fsec Including:\n' ...
    '     Data access time fraction: %5.1f%%; Transf. time frac.: %5.1f%%; Resulting pix preparation: %5.1f%%\n'], ...
    total_proj_time,100*pix_read_time/total_proj_time,100*data_proc_time/total_proj_time,100*pix_accum_time/total_proj_time)
disp('--------------------------------------------------------------------------------')

end
