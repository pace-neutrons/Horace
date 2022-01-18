function [s, e, npix, pix_out, pix_comb_info] = ...
    cut_accumulate_data_(obj, proj, axes,keep_pixels, log_level, return_cut)
%%CUT_ACCUMULATE_DATA Accumulate image and pixel data for a cut
%
% Input:
% ------
% proj       A 'projection' object, defining the projection of the cut.
% axes       A 'axes_block' object defining the ranges, binning and geometry
%            of the target cut
% keep_pixels A boolean defining whether pixel data should be retained. If this
%            is false return variable 'pix_out' will be empty.
% log_level  The verbosity of the log messages. The values correspond to those
%            used in 'hor_config', see `help hor_config/log_level`.
% return_cut If true, the cut is intended to be returned as an object and
%            pixels must be returned in memory. If false, we allow pixels to be
%            held in temporary files managed by a pix_combine_info object.
%
% Output:
% -------
% s              The image signal data.
% e              The variance in the image signal data.
% npix           Array defining how many pixels are contained in each image
%                bin. size(npix) == size(s)
% pix_out        A PixelData object containing pixels that contribute to the
%                cut.
% pix_combine_info Temp file manager/combiner class instance for performing
%                  out-of-memory cuts. If keep_pix is false, or return_cut
%                  is true, this will be empty.
%
% CALLED BY cut_single
%

pix_comb_info = [];

% Pre-allocate image data
[~,sz1] = axes.data_dims();
% note that 1D allocator of size N returns NxN array while we need Nx1
% array
%nbin_as_size = get_nbin_as_size(sz1);
s = zeros(sz1);
e = zeros(sz1);
npix = zeros(sz1);

% Get bins that may contain pixels that contribute to the cut.
% The bins selected are those that sit within (or intersect) the bounds of the
% cut. See the relevant projection function for more details.
header_av = header_average(obj);
sproj = obj.data.get_projection(header_av);
[bloc_starts, block_sizes] = sproj.get_nrange(obj.data.npix,obj.data,axes,proj);
if isempty(bloc_starts)
    % No pixels in range, we can return early
    pix_out = PixelData();
    pix_comb_info = [];
    return
end
if obj.data.pix.is_filebacked()
    hc = hor_config;
    chunk_size = hc.mem_chunk_size;
    % Get indices in order to split the candidate bin ranges into chunks whose sums
    % are less than, or equal to, a pixel page size
    block_chunks = split_data_blocks(bloc_starts,block_sizes, chunk_size);
    num_chunks = numel(block_chunks);
else
    num_chunks = 1;
    block_chunks = {bloc_starts,block_sizes};
end
% If we only have one iteration of pixels to cut then we must be able to fit
% all pixels in memory, hence no need to use temporary files.
use_tmp_files = ~return_cut && num_chunks > 1;
if keep_pixels
    % Pre-allocate cell arrays to hold PixelData chunks
    pix_retained = cell(1, num_chunks);
    pix_ix_retained = cell(1,num_chunks);
    %
    if use_tmp_files
        % Create a pix_comb_info object to handle tmp files of pixels
        num_bins = numel(s);
        pix_comb_info = init_pix_combine_info(num_chunks, num_bins);
    else
        pix_comb_info = [];
    end
end
if keep_pixels && use_tmp_files
    clearPixAccum = onCleanup(@()cut_data_from_file_job.accumulate_pix_to_file('cleanup'));
end
if keep_pixels && ~use_tmp_files
    keep_precision = false; % change single precision to double precision for further operations
else
    keep_precision = true;
end
%
if num_chunks == 1
    pix_start = block_chunks{1};
    block_sizes = block_chunks{2};
    candidate_pix = obj.data.pix.get_pix_in_ranges( ...
        pix_start, block_sizes, false,keep_precision);
    if log_level >= 1
        fprintf(['Got data for %d pixels -- ' ...
            'processing data...'], ...
            candidate_pix.num_pixels);
    end
    
    if keep_pixels
        [npix,s,e,pix_ok] = proj.bin_pixels(axes,candidate_pix,npix,s,e);
    else
        [npix,s,e] = proj.bin_pixels(axes,candidate_pix,npix,s,e);
        pix_ok = [];
    end
    pix_retained{1} = pix_ok;%candidate_pix.get_pixels(ok);
    pix_ix_retained{1} = [];
else
    for iter = 1:num_chunks
        % Get pixels that will likely contribute to the cut
        chunk = block_chunks{iter};
        pix_start = chunk{1};
        block_sizes = chunk{2};
        candidate_pix = obj.data.pix.get_pix_in_ranges( ...
            pix_start, block_sizes, false,keep_precision);
        
        if log_level >= 1
            fprintf(['Step %3d of %3d; Read data for %d pixels -- ' ...
                'processing data...'], iter, num_chunks, ...
                candidate_pix.num_pixels);
        end
        if keep_pixels
            [npix,s,e,pix_ok,pix_indx] = proj.bin_pixels(axes,candidate_pix,npix,s,e);
        else
            [npix,s,e] = proj.bin_pixels(axes,candidate_pix,npix,s,e);
            pix_ok = [];
        end
        
        if log_level >= 1
            fprintf(' ----->  retained  %d pixels\n', del_npix_retain);
        end
        if keep_pixels
            if use_tmp_files
                % Generate tmp files and get a pix_combine_info object to manage
                % the files - this object then recombines the files once it is
                % passed to 'put_sqw'.
                pix_comb_info = cut_data_from_file_job.accumulate_pix_to_file( ...
                    pix_comb_info, false, candidate_pix, ok, pix_indx, npix, block_size, ...
                    del_npix_retain ...
                    );
            else
                % Retain only the pixels that contributed to the cut
                pix_retained{iter}    = pix_ok;    %candidate_pix.get_pixels(ok);
                pix_ix_retained{iter} = pix_indx;
            end
        end
    end  % loop over pixel blocks
end

if keep_pixels
    if num_chunks > 1
        [pix_out, pix_comb_info] = combine_pixels( ...
            pix_retained, pix_ix_retained, npix, block_size ...
            );
    else % all done
    end
else
    pix_out = PixelData();
end

[s, e] = normalize_signal(s, e, npix);

end  % function

function [s, e] = normalize_signal(s, e, npix)
% Convert summed signal & error into averages
s = s./npix;
e = e./(npix.^2);
no_pix = (npix == 0);  % true where no pixels contribute to given bin

% By convention, signal and error are zero if no pixels contribute to bin
s(no_pix) = 0;
e(no_pix) = 0;
end


function pci = init_pix_combine_info(nfiles, nbins)
% Create a pix_combine_info object to manage temporary files of pixels
wk_dir = get(parallel_config, 'working_directory');
tmp_file_names = gen_unique_file_paths(nfiles, 'horace_cut', wk_dir);
pci = pix_combine_info(tmp_file_names, nbins);
end


function [pix, pix_comb_info] = combine_pixels( ...
    pix_retained, pix_ix_retained,npix, buf_size ...
    )
% Combine and sort in-memory pixels or finalize accumulation of pixels in
% temporary files managed by a pix_combine_info object.
if isa(pix_retained,'pix_comb_info')
    % Pixels are stored in tmp files managed by pix_combine_info object
    pix = PixelData();
    finish_accumulation = true;
    pix_comb_info = cut_data_from_file_job.accumulate_pix_to_file( ...
        pix_retained, finish_accumulation, pix, [], [], npix, buf_size, 0 ...
        );
else
    % Pixels stored in-memory in PixelData object
    pix = sort_pix(pix_retained, pix_ix_retained, npix);
end
end
