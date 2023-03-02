function wout = do_sqw_eval_memory_(wout, sqwfunc, pars, average)
% Perform sqw_eval on an sqw object with all its pixels in memory
%
qw_pix_coords = calculate_qw_pixels(wout);
if average
    % Get average h, k, l, e for the bin, compute sqw for that average,
    % and fill pixels with the average signal for the bin that contains
    % them
    qw_ave = wout.average_bin_data_(qw_pix_coords);
    qw_ave = cellfun(@(x)(x(:)), qw_ave, 'UniformOutput', false);
    new_signal = sqwfunc(qw_ave{:}, pars{:});
    new_signal = repelem(new_signal, wout.data.npix(:));
else
    new_signal = sqwfunc(qw_pix_coords{:}, pars{:});
end

wout.pix.signal = new_signal(:)';
wout.pix.variance = zeros(1, numel(new_signal));
wout = recompute_bin_data(wout);

end
