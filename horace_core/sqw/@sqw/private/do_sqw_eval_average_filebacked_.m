function wout = do_sqw_eval_average_filebacked_(wout, sqwfunc, pars, outfile)
%==============================================================================
% Execute the given function 'sqwfunc' on the average coordinates (in
% r, l, u) for each image bin
%
%==============================================================================

[wout, ldr] = wout.get_new_handle(outfile);
ldr_clob = onCleanup(@() ldr.delete());

% Split npix array up, this allows us to pass the npix chunks into
% 'average_bin_data', for which we need whole bins.
npix = wout.data.npix;

[npix_chunks, idxs, npix_cumsum] = split_vector_max_sum(npix(:), wout.pix.DEFAULT_PAGE_SIZE);
pix_bin_starts = npix_cumsum - npix(:) + 1;

for i = 1:numel(npix_chunks)
    npix_chunk = npix_chunks{i};
    pix_start_idx = pix_bin_starts(idxs(1, i));
    pix_end_idx   = npix_cumsum(idxs(2, i));
    pix_block_sizes = pix_end_idx-pix_start_idx+1;

    % Get pixels that belong to the bins in the current npix chunk
    pix_chunk = wout.pix.get_pix_in_ranges(pix_start_idx, pix_block_sizes, false);

    % Calculate qh, qk, ql, and en for the pixels (qw_pix is cell array)
    qw_pix = get_qw_pixels_(wout, pix_chunk);

    % Average the qw pixel data over each bin defined by the npix chunk
    qw_ave = average_bin_data(npix_chunk, qw_pix);
    qw_ave = cellfun(@(x) x(:), qw_ave, 'UniformOutput', false);

    % Perform input function over the averaged image data
    ave_signal = sqwfunc(qw_ave{:}, pars{:});

    % Assign each pixel's signal to bin average, variance set to zero
    sig_var = [repelem(ave_signal, npix_chunk)'; ...
               zeros(1, pix_block_sizes)];

    pix_chunk = pix_chunk.set_fields(sig_var, {'signal', 'variance'});
    pix_chunk = pix_chunk.reset_changed_coord_range({'signal', 'variance'});

    wout.pix.format_dump_data(pix_chunk.data, pix_start_idx);

end

wout.pix = wout.pix.finalise();
wout = recompute_bin_data(wout);

% Now go back and overwrite the old image in the file with new data
% ldr.put_dnd(wout);

end % of function do_sqw_eval_average_filebacked

function qw_pix = get_qw_pixels_(sqw_obj, pix)
    sqw_obj.pix = pix;
    qw_pix = calculate_qw_pixels(sqw_obj);
end

function qw_ave = average_qw_pix_(sqw_obj, pix, npix)
    ab = ortho_axes('nbins_all_dims',[numel(npix),1,1,1],'img_range',sqw_obj.data.img_range);
    sqw_obj.data = d1d(ab,sqw_obj.data.proj);
    sqw_obj.data.npix = npix;
    qw_ave = average_bin_data(sqw_obj, pix);
    qw_ave = cellfun(@(x) x(:), qw_ave, 'UniformOutput', false);
end

function pix = set_pixel_data_(pix, ave_signal, npix_chunk, start_idx, end_idx)
    sig_var = zeros(2, end_idx - start_idx + 1);
    sig_var(1, :) = repelem(ave_signal, npix_chunk);
    pix.set_data({'signal', 'variance'}, sig_var, start_idx:end_idx);
end

function [s, e] = get_image_bin_averages_(bin_sums, npix)
    s = reshape(bin_sums(:)./npix(:), size(npix));
    s(npix == 0) = 0;
    e = zeros(size(s));
end
