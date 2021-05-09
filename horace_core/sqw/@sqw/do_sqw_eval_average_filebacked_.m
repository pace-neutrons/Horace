function sqw_obj = do_sqw_eval_average_filebacked_(sqw_obj, sqwfunc, pars, outfile)
%==============================================================================
% Execute the given function 'sqwfunc' on the average coordinates (in
% r, l, u) for each image bin
%
%==============================================================================

pix = sqw_obj.data.pix;
npix = sqw_obj.data.npix;

% Split npix array up, this allows us to pass the npix chunks into
% 'average_bin_data', for which we need whole bins.
[npix_chunks, idxs, pix_bin_ends] = split_vector_max_sum(npix(:), pix.base_page_size);
pix_bin_starts = pix_bin_ends - npix(:) + 1;

for j = 1:numel(npix_chunks)
    npix_chunk = npix_chunks{j};
    pix_start_idx = pix_bin_starts(idxs(1, j));
    pix_end_idx   = pix_bin_ends(idxs(2, j));

    % Get pixels that belong to the bins in the current npix chunk
    pix_chunk = pix.get_pix_in_ranges(pix_start_idx, pix_end_idx);

    % Calculate qh, qk, ql, and en for the pixels (qw_pix is cell array)
    qw_pix = get_qw_pixels_(sqw_obj, pix_chunk);

    % Average the qw pixel data over each bin defined by the npix chunk
    qw_ave = average_qw_pix_(sqw_obj, qw_pix, npix_chunk);

    % Perform input function over the averaged image data
    ave_signal = sqwfunc(qw_ave{:}, pars{:});

    % Assign each pixel's signal to bin average, variance set to zero
    pix = set_pixel_data_(pix, ave_signal, npix_chunk, pix_start_idx, pix_end_idx);
end
sqw_obj = recompute_bin_data(sqw_obj);
save(sqw_obj, outfile);

end % of function do_sqw_eval_average_filebacked

%------------------------------------------------------------------------------
function qw_pix = get_qw_pixels_(sqw_obj, pix)
    sqw_obj.data.pix = pix;
    qw_pix = calculate_qw_pixels(sqw_obj);
end

%------------------------------------------------------------------------------
function qw_ave = average_qw_pix_(sqw_obj, pix, npix)
    sqw_obj.data.npix = npix;
    qw_ave = average_bin_data(sqw_obj, pix);
    qw_ave = cellfun(@(x) x(:), qw_ave, 'UniformOutput', false);
end

%------------------------------------------------------------------------------
function pix = set_pixel_data_(pix, ave_signal, npix_chunk, start_idx, end_idx)
    sig_var = zeros(2, end_idx - start_idx + 1);
    sig_var(1, :) = repelem(ave_signal, npix_chunk);
    pix.set_data({'signal', 'variance'}, sig_var, start_idx:end_idx);
end

%==============================================================================

