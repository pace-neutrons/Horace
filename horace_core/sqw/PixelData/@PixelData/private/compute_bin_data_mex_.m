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

pg_size = min(obj.max_page_size_, obj.num_pixels);
npix_cum_sum = cumsum(npix);
signal_sum = zeros(size(npix));
variance_sum = zeros(size(npix));

while true
    start_idx = find(npix_cum_sum > 0, 1);
    leftover_begin = npix_cum_sum(start_idx);

    npix_cum_sum = npix_cum_sum - pg_size;
    end_idx = find(npix_cum_sum > 0, 1);
    if isempty(end_idx)
        end_idx = numel(npix);
    end

    if start_idx == end_idx
        npix_chunk = min(pg_size, npix(start_idx) - leftover_end);
    else
        leftover_end = pg_size - (leftover_begin + sum(npix(start_idx + 1:end_idx - 1)));
        leftover_end = min(leftover_end, npix(end_idx));
        npix_chunk = [leftover_begin, npix(start_idx + 1:end_idx - 1)', leftover_end];
    end

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
