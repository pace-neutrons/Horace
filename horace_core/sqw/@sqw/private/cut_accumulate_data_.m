function [s, e, npix, pix_out,unique_runid] = ...
    cut_accumulate_data_(obj, targ_proj, targ_axes,keep_pixels, log_level, return_cut)
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
% return_cut If true, the cut is intended to be returned as an object and
%            pixels must be returned in memory. If false, we allow pixels to be
%            held in temporary files managed by a pix_combine_info object.
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
sz1 = targ_axes.dims_as_ssize();
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
    [block_starts, block_sizes] = sproj.get_nrange(obj.data.npix,saxes,targ_axes,targ_proj);
end

if isempty(block_starts)
    report_cut_type(obj,log_level-1,false,keep_pixels);

    % No pixels in range, we can return early
    pix_out = PixelDataBase.create();
    unique_runid = [];
    return
end

n_candidate_pix = sum(block_sizes);


cut_in_mem = ~obj.pix.is_filebacked || ~PixelDataBase.do_filebacked(n_candidate_pix);
cut_to_file = ~return_cut;

if ~cut_to_file && ~PixelDataBase.do_filebacked(n_candidate_pix, 10)
    warning('HORACE:cut:large_cut', ['Requested cut may retain up to %d pixel indices, which may exceed system memory\n', ...
                                     'Suggested fix: use cut with ''-save''\n', ...
                                     'Recommended limit: 10*mem_chunk_size (%d)'], ...
            n_candidate_pix, 10*get(hor_config, 'mem_chunk_size'));
end

keep_precision = ~keep_pixels || cut_to_file;
pixel_contrib_name = report_cut_type(obj, log_level, cut_to_file, keep_pixels);

if cut_to_file
    [npix, s, e, pix_out, unique_runid] = cut_tmp_files(obj.pix, block_starts, block_sizes, ...
                                                        targ_proj, targ_axes, npix, s, e, ...
                                                        log_level, keep_precision, pixel_contrib_name);

elseif cut_in_mem && keep_pixels
    [npix, s, e, pix_out, unique_runid] = cut_in_memory_w_pixels(obj.pix, block_starts, block_sizes, targ_proj, ...
                                                                targ_axes, npix, s, e, log_level, pixel_contrib_name);

elseif cut_in_mem
    [npix, s, e, pix_out, unique_runid] = cut_in_memory_no_pixels(obj.pix, block_starts, block_sizes, targ_proj, ...
                                                                 targ_axes, npix, s, e, log_level, pixel_contrib_name);
elseif keep_pixels
    [npix, s, e, pix_out, unique_runid] = cut_filebacked_w_pixels(obj.pix, block_starts, block_sizes, targ_proj, ...
                                                                  targ_axes, npix, s, e, log_level, pixel_contrib_name);

else

    [npix, s, e, pix_out, unique_runid] = cut_filebacked_no_pixels(obj.pix, block_starts, block_sizes, targ_proj, ...
                                                                   targ_axes, npix, s, e, log_level, pixel_contrib_name);

end

[s, e] = normalize_signal(s, e, npix);

end  % function

function [npix, s, e, pix_retained, unique_runid] = cut_in_memory_w_pixels(pix, block_starts, block_sizes, ...
                                                                           targ_proj, targ_axes, npix, s, e, ll, ...
                                                                           pixel_contrib_name)

    candidate_pix = pix.get_pix_in_ranges(block_starts, block_sizes, false, false);

    if ll >= 1
        fprintf('*** Got data for %d pixels -- processing data...', candidate_pix.num_pixels);
    end

    [npix, s, e, pix_retained, unique_runid] = targ_proj.bin_pixels(targ_axes, candidate_pix, npix, s, e);
    npix_step_retained = pix_retained.num_pixels; % just for logging the progress

    if ll >= 1
        fprintf(' ----->  %s  %d pixels\n', pixel_contrib_name, npix_step_retained);
    end
end

function [npix, s, e, pix_retained, unique_runid] = cut_in_memory_no_pixels(pix, block_starts, block_sizes, ...
                                                                            targ_proj, targ_axes, npix, s, e, ll, ...
                                                                            pixel_contrib_name)

    candidate_pix = pix.get_pix_in_ranges(block_starts, block_sizes, false, true);

    if ll >= 1
        fprintf('*** Got data for %d pixels -- processing data...', candidate_pix.num_pixels);
    end

    [npix, s, e] = targ_proj.bin_pixels(targ_axes,candidate_pix,npix,s,e);

    if ll >= 1
        npix_step_retained = sum(npix(:));

        fprintf(' ----->  %s  %d pixels\n', pixel_contrib_name, npix_step_retained);
    end

    pix_retained = PixelDataBase.create();
    unique_runid = [];

end

function [npix, s, e, pix_out, unique_runid] = cut_filebacked_w_pixels(pix, block_starts, block_sizes, ...
                                                                       targ_proj, targ_axes, npix, s, e, ll, ...
                                                                       pixel_contrib_name)

    hc = hor_config;
    chunk_size = hc.mem_chunk_size;
    % Get indices in order to split the candidate bin ranges into chunks whose sums
    % are less than, or equal to, a pixel page size
    block_chunks = split_data_blocks(block_starts,block_sizes, chunk_size);
    num_chunks = numel(block_chunks);

    npix_tot_retained = 0;

    unique_runid = [];

    pix_retained = PixelDataFileBacked().get_new_handle();
    pix_ix_retained = cell(1, num_chunks);

    for iter = 1:num_chunks
        % Get pixels that will likely contribute to the cut
        chunk = block_chunks{iter};
        pix_start = chunk{1};
        block_sizes = chunk{2};

        candidate_pix = pix.get_pix_in_ranges(pix_start, block_sizes, false, false);

        if ll >= 1
            fprintf('*** Step %d of %d; Read data for %d pixels -- processing data...', ...
                    iter, num_chunks, candidate_pix.num_pixels);
        end

        % Pix not sorted here
        [npix, s, e, pix_ok, unique_runid_l, pix_indx] = ...
            targ_proj.bin_pixels(targ_axes, candidate_pix, npix, s, e);

        npix_step_retained = pix_ok.num_pixels; % just for logging the progress
        npix_tot_retained = npix_tot_retained + npix_step_retained;
        unique_runid = unique([unique_runid,unique_runid_l(:)']);

        if ll >= 1
            fprintf(' ----->  %s  %d pixels\n', pixel_contrib_name, npix_step_retained);
        end

        % Retain only the pixels that contributed to the cut
        pix_retained.format_dump_data(pix_ok.data);
        pix_ix_retained{iter} = pix_indx;

    end  % loop over pixel blocks

    pix_retained = pix_retained.finalise(npix_tot_retained);
    pix_out = sort_pix(pix_retained, pix_ix_retained, npix);

end

function [npix, s, e, pix_out, unique_runid] = cut_filebacked_no_pixels(pix, block_starts, block_sizes, ...
                                                                        targ_proj, targ_axes, npix, s, e, ll, ...
                                                                        pixel_contrib_name)

    hc = hor_config;
    chunk_size = hc.mem_chunk_size;
    % Get indices in order to split the candidate bin ranges into chunks whose sums
    % are less than, or equal to, a pixel page size
    block_chunks = split_data_blocks(block_starts,block_sizes, chunk_size);
    num_chunks = numel(block_chunks);

    for iter = 1:num_chunks
        % Get pixels that will likely contribute to the cut
        chunk = block_chunks{iter};
        pix_start = chunk{1};
        block_sizes = chunk{2};

        candidate_pix = pix.get_pix_in_ranges(pix_start, block_sizes, false, true);

        if ll >= 1
            fprintf('*** Step %d of %d; Read data for %d pixels -- processing data...', ...
                    iter, num_chunks, candidate_pix.num_pixels);
        end

        [npix,s,e] = targ_proj.bin_pixels(targ_axes,candidate_pix,npix,s,e);

        if ll >= 1
            npsr = sum(npix(:));
            npix_step_retained = npsr - npix_tot_retained;
            npix_tot_retained = npsr;

            fprintf(' ----->  %s  %d pixels\n', pixel_contrib_name, npix_step_retained);
        end

    end  % loop over pixel blocks

    pix_out = PixelDataBase.create();
    unique_runid = [];

end

function [npix, s, e, pix_out, unique_runid] = cut_tmp_files(pix, block_starts, block_sizes, ...
                                                             targ_proj, targ_axes, npix, s, e, ll, ...
                                                             keep_precision, pixel_contrib_name)

    hc = hor_config;
    chunk_size = hc.mem_chunk_size;

    % Get indices in order to split the candidate bin ranges into chunks whose sums
    % are less than, or equal to, a pixel page size
    block_chunks = split_data_blocks(block_starts,block_sizes, chunk_size);
    num_chunks = numel(block_chunks);

    % Create a pix_comb_info object to handle tmp files of pixels
    num_bins = numel(s);
    pix_comb_info = init_pix_combine_info(num_chunks, num_bins);
    clearPixAccum = onCleanup(@() cut_data_from_file_job.accumulate_pix_to_file('cleanup'));

    unique_runid = [];

    for iter = 1:num_chunks
        % Get pixels that will likely contribute to the cut
        chunk = block_chunks{iter};
        pix_start = chunk{1};
        block_sizes = chunk{2};

        candidate_pix = pix.get_pix_in_ranges(pix_start, block_sizes, false, keep_precision);

        if ll >= 1
            fprintf('*** Step %d of %d; Read data for %d pixels -- processing data...', ...
                    iter, num_chunks, candidate_pix.num_pixels);
        end

        % Pix not sorted here
        [npix, s, e, pix_ok, unique_runid_l, pix_indx] = ...
            targ_proj.bin_pixels(targ_axes, candidate_pix, npix, s, e);
        npix_step_retained = pix_ok.num_pixels; % just for logging the progress
        unique_runid = unique([unique_runid,unique_runid_l(:)']);

        if ll >= 1
            fprintf(' ----->  %s  %d pixels\n', pixel_contrib_name, npix_step_retained);
        end

        % Generate tmp files and get a pix_combine_info object to manage
        % the files - this object then recombines the files once it is
        % passed to 'put_sqw'.
        pix_comb_info = cut_data_from_file_job.accumulate_pix_to_file(pix_comb_info, false, ...
                                                                      pix_ok, pix_indx, npix, chunk_size);
    end  % loop over pixel blocks

    % store partial pixel_blocks remaining memory to tmp files
    % return pix_out which here is the pix_combine_info.
    % clear pix_block from memory.
    pix_out = cut_data_from_file_job.accumulate_pix_to_file(pix_comb_info, true);

end

function pci = init_pix_combine_info(nfiles, nbins)
% Create a pix_combine_info object to manage temporary files of pixels
    wk_dir = get(parallel_config, 'working_directory');
    tmp_file_names = gen_unique_file_paths(nfiles, 'horace_cut', wk_dir);
    pci = pix_combine_info(tmp_file_names, nbins);

end

function pixel_contrib_name = report_cut_type(obj,log_level,use_tmp_files,keep_pixels)
% Routine prints the information about the cut type and how it would be
% done to inform user about the intended cut and expected results.
%
% in some situations report that no data contribute to the cut and the cut
% is not performed.
%
if isa(obj,'sqw')
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

if nargin == 4  && log_level > 1 % no pixels contributed in the cut
    if use_tmp_files
        fprintf('*** Cutting %s sqw object; returning result %s --> ignored as cut contains no pixels\n',...
            obj_type,target);
    else
        fprintf('*** Cutting %s sqw object; returning result %s; cut contains no pixels\n',...
            obj_type,target);
    end
else
    fprintf('*** Cutting %s sqw object; returning result %s; retuning pixels - %s\n',...
        obj_type,target,pix_state);
end

end
