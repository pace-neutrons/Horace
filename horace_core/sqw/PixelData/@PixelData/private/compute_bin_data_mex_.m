function [mean_signal, mean_variance] = compute_bin_data_mex_(obj, npix, n_threads)
% Compute bin mean signal and variance using mex library
%
% See compute_bin_data for algorithm details
%

if isempty(obj)
    return;
end

if nargin < 3
    n_threads = config_store.instance().get_value('hor_config','threads');
end

obj.move_to_first_page();

% Get a cumulative sum to track which pixels have been processed
npix_cum_sum = cumsum(npix(:));

end_idx = 1;
signal_sum = zeros(1, numel(npix));
variance_sum = zeros(1, numel(npix));

end_idx = 1;
% Loop over pages of data
while true
    % Find the index of the first bin to allocate pixels to.
    % We subtract allocated pixels from the cumulative sum later, so the first
    % bin to allocate pixels to will be the first bin with cumulative sum > 0
    start_idx = (end_idx - 1) + find(npix_cum_sum(end_idx:end) > 0, 1);
    % Get number of pixels to allocate to bin n, that weren't allocated on
    % the last iteration
    leftover_begin = npix_cum_sum(start_idx);

    % Subtract allocated pixels from the npix cumulative sum
    npix_cum_sum = npix_cum_sum - obj.page_size;
    % Find the index of the last bin to allocate pixels to
    end_idx = (start_idx - 1) + find(npix_cum_sum(start_idx:end) > 0, 1);
    if isempty(end_idx)
        % No end index found, must be at the end of the npix array
        end_idx = numel(npix);
    end

    if start_idx == end_idx
        % All pixels in page
        if ~exist('leftover_end', 'var')
            leftover_end = 0;
        end
        npix_chunk = min(obj.page_size, npix(start_idx) - leftover_end);
    else
        % Leftover_end = number of pixels to allocate to final bin n,
        % there will be more pixels to allocate to bin n in the next iteration
        leftover_end = ...
            obj.page_size - (leftover_begin + sum(npix(start_idx + 1:end_idx - 1)));
        npix_chunk = npix(start_idx + 1:end_idx - 1);
        npix_chunk = [leftover_begin, npix_chunk(:).', leftover_end];
    end

    % Calculate and accumulate signal/variance sums
    [sig, variance] = compute_pix_sums_c(npix_chunk, obj.data, n_threads);
    signal_sum(start_idx:end_idx) = signal_sum(start_idx:end_idx) + sig;
    variance_sum(start_idx:end_idx) = variance_sum(start_idx:end_idx) + variance;

    if obj.has_more()
        obj.advance();
    else
        break
    end
end
signal_sum = reshape(signal_sum, size(npix));
variance_sum = reshape(variance_sum, size(npix));

mean_signal = signal_sum./npix;
mean_variance = variance_sum./npix.^2;

% Convert NaNs to zeros (bins where we divide by zero have no pixel contributions)
nopix = (npix(:) == 0);
mean_signal(nopix) = 0;
mean_variance(nopix) = 0;
