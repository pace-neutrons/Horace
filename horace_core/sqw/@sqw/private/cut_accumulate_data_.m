function [s, e, npix, pix_out, urange_pix] = ...
    cut_accumulate_data_(obj, proj, keep_pix, log_level)
%%CUT_ACCUMULATE_DATA Accumulate image and pixel data for a cut
%
% Input:
% ------
% proj       A 'projection' object, defining the project of the cut.
% keep_pix   A boolean defining whether pixel data should be retained. If this
%            is false return variable 'pix_out' will be empty.
% log_level  The verbosity of the log messages. The values correspond to those
%            used in 'hor_config', see `help hor_config/log_level`.
%
% Output:
% -------
% s                The image signal data.
% e                The variance in the image signal data.
% npix             Array defining how many pixels are contained in each image
%                  bin. size(npix) == size(s)
% pix_out          A PixelData object containing pixels that contribute to the
%                  cut.
% urange_pix       The range of u1, u2, u3, and dE in the contributing pixels.
%                  size(urange_step_pix) == [2, 4].
%
% CALLED BY cut_single
%

% Pre-allocate image data
nbin_as_size = get_nbin_as_size(proj.target_nbin);
s = zeros(nbin_as_size);
e = zeros(nbin_as_size);
npix = zeros(nbin_as_size);
urange_step_pix = [Inf(1, 4); -Inf(1, 4)];

[bin_starts, bin_ends] = proj.get_nbin_range(obj.data.npix);
if isempty(bin_starts)
    % No pixels in range, we can return early
    pix_out = PixelData();
    urange_pix = urange_step_pix;
    return
end

% Get the cumulative sum of pixel bin sizes and work out how many
% iterations we're going to need
cum_bin_sizes = cumsum(bin_ends - bin_starts);
block_size = obj.data.pix.base_page_size;
max_num_iters = ceil(cum_bin_sizes(end)/block_size);

% Pre-allocate cell arrays to hold PixelData chunks
pix_retained = cell(1, max_num_iters);
pix_ix_retained = cell(1, max_num_iters);

block_end_idx = 0;
for iter = 1:max_num_iters
    block_start_idx = block_end_idx + 1;
    if block_start_idx > numel(cum_bin_sizes)
        % If start index has reached end of bin sizes, we've reached the end
        break
    end

    % Work out how many full bins we can load given we only want to load
    % block_size number of pixels
    next_idx_end = find(cum_bin_sizes(block_start_idx:end) > block_size, 1);
    block_end_idx = block_end_idx + next_idx_end - 1;
    if isempty(block_end_idx)
        % There are less than block_size no. of pixels in the remaining bins
        block_end_idx = numel(cum_bin_sizes);
    end

    if block_start_idx > block_end_idx
        % Occurs where bin size greater than block size, just read in the
        % whole bin
        block_end_idx = block_start_idx;
        pix_assigned = bin_ends(block_end_idx) - bin_starts(block_start_idx);
    else
        pix_assigned = block_size;
    end

    % Subtract the number of pixels we've assigned from our cumulative sum
    cum_bin_sizes = cum_bin_sizes - pix_assigned;

    % Get pixels that will likely contribute to the cut
    candidate_pix = obj.data.pix.get_pix_in_ranges( ...
        bin_starts(block_start_idx:block_end_idx), ...
        bin_ends(block_start_idx:block_end_idx) ...
    );

    if log_level >= 0
        fprintf(['Step %3d of maximum %3d; Have read data for %d pixels -- ' ...
                    'now processing data...'], iter, max_num_iters, ...
                candidate_pix.num_pixels);
    end

    [ ...
        s, ...
        e, ...
        npix, ...
        urange_step_pix, ...
        del_npix_retain, ...
        ok, ...
        ix ...
    ] = cut_data_from_file_job.accumulate_cut( ...
            s, ...
            e, ...
            npix, ...
            urange_step_pix, ...
            keep_pix, ...
            candidate_pix, ...
            proj, ...
            proj.target_pax ...
    );

    if log_level >= 0
        fprintf(' ----->  retained  %d pixels\n', del_npix_retain);
    end

    if keep_pix
        % TODO: If cutting from file to file with no return value, use
        % PixelData.append to deal with temporary files, so we don't need to
        % hold all pixels in memory.

        % Retain only the pixels that contributed to the cut
        pix_retained{iter} = candidate_pix.get_pixels(ok);
        pix_ix_retained{iter} = ix;
    end

end  % loop over pixel blocks

if keep_pix
    pix_out = sort_pix(pix_retained, pix_ix_retained, npix);
else
    pix_out = PixelData();
end

% Convert range from steps to actual range with respect to output uoffset
urange_offset = repmat(proj.urange_offset, [2, 1]);
urange_pix = urange_step_pix.*repmat(proj.usteps, [2, 1]) + urange_offset;

[s, e] = average_signal(s, e, npix);

end  % function


% -----------------------------------------------------------------------------
function nbin_as_size = get_nbin_as_size(nbin)
    % Get the given nbin array as a size

    % Note: Matlab silliness when one dimensional: MUST add an outer dimension
    % of unity. For 2D and higher, outer dimensions can always be assumed.
    % The problem with 1D is that e.g. zeros([5]) is not the same as
    % zeros([5,1]) whereas zeros([5,3]) is the same as zeros([5,3,1]).
    if isempty(nbin)
        nbin_as_size = [1, 1];
    elseif length(nbin) == 1
        nbin_as_size = [nbin, 1];
    else
        nbin_as_size = nbin;
    end
end


function [s, e] = average_signal(s, e, npix)
    % Convert summed signal & error into averages
    s = s./npix;
    e = e./(npix.^2);
    no_pix = (npix == 0);  % true where no pixels contribute to given bin

    % By convention, signal and error are zero if no pixels contribute to bin
    s(no_pix) = 0;
    e(no_pix) = 0;
end
