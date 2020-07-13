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

% get a cumulative sum to track which pixels have been processed
npix_cum_sum = cumsum(npix);

% pre-allocate the signal and variance arrays
signal_sum = zeros(size(npix));
variance_sum = zeros(size(npix));

% loop over pages of data
while true
    % find the index of the first bin to allocate pixels to
    % we subtract allocated pixels from the cumulative sum later, so the first
    % bin to allocate pixels to will be the first bin with cumulative sum > 0
    start_idx = find(npix_cum_sum > 0, 1);
    % get number of pixels to allocate to bin n, that weren't allocated on
    % the last iteration
    leftover_begin = npix_cum_sum(start_idx);

    % subtrack allocated pixels from the npix cumulative sum
    npix_cum_sum = npix_cum_sum - obj.page_size;
    % find the index of the last bin to allocate pixels to
    end_idx = find(npix_cum_sum > 0, 1);
    if isempty(end_idx)
        % no end index found, must be at the end of the npix array
        end_idx = numel(npix);
    end

    if start_idx == end_idx
        % all pixels in page
        npix_chunk = min(obj.page_size, npix(start_idx) - leftover_end);
    else
        % leftover_end = number of pixels to allocate to final bin n, there will
        % be more pixels to allocated to bin n in the next iteration
        leftover_end = ...
            obj.page_size - (leftover_begin + sum(npix(start_idx + 1:end_idx - 1)));
        npix_chunk = [leftover_begin, npix(start_idx + 1:end_idx - 1)', leftover_end];
    end

    % calculate and accumulate signal/variance sums
    [sig, variance] = recompute_bin_data_c(npix_chunk, obj.data, n_threads);
    signal_sum(start_idx:end_idx) = signal_sum(start_idx:end_idx) + sig';
    variance_sum(start_idx:end_idx) = variance_sum(start_idx:end_idx) + variance';

    if obj.has_more()
        obj.advance();
    else
        break
    end
end

mean_signal = signal_sum./npix(:);
mean_variance = variance_sum./npix(:).^2;
