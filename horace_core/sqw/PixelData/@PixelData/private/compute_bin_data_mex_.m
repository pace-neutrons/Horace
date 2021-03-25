function [mean_signal, mean_variance] = compute_bin_data_mex_(obj, npix, n_threads)
% Compute bin mean signal and variance using mex library
%
% See compute_bin_data for algorithm details
%

if isempty(obj)
    mean_signal = [];
    mean_variance = [];
    return;
end

if nargin < 3
    n_threads = config_store.instance().get_value('hor_config','threads');
end

obj.move_to_first_page();
[npix_chunks, idxs] = split_vector_fixed_sum(npix(:), obj.base_page_size);

signal_sum = zeros(1, numel(npix));
variance_sum = zeros(1, numel(npix));
page_number = 1;
% Loop over pages of data
while true
    npix_for_page = npix_chunks{page_number};
    idx = idxs(:, page_number);

    % Calculate and accumulate signal/variance sums
    [sig, variance] = compute_pix_sums_c(npix_for_page, obj.data, n_threads);
    signal_sum(idx(1):idx(2)) = signal_sum(idx(1):idx(2)) + sig;
    variance_sum(idx(1):idx(2)) = variance_sum(idx(1):idx(2)) + variance;

    if obj.has_more()
        obj.advance();
        page_number = page_number + 1;
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
