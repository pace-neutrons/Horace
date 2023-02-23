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
% TODO, drop internal page size, revert everything to configuration
%     [n_threads,buf_size] = config_store.instance().get_value(...
%         'hor_config','threads','mem_chunk_size');
     [n_threads] = get(parallel_config,'threads');

end

[npix_chunks, idxs] = split_vector_fixed_sum(npix(:), obj.base_page_size);

signal_sum = zeros(1, numel(npix));
variance_sum = zeros(1, numel(npix));

% Loop over pages of data
for page_number = 1:obj.num_pages
    obj.page_num = page_number;
    npix_for_page = npix_chunks{page_number};
    idx = idxs(:, page_number);

    % Calculate and accumulate signal/variance sums
    [sig, variance] = compute_pix_sums_c(npix_for_page, obj.data, n_threads);
    signal_sum(idx(1):idx(2)) = signal_sum(idx(1):idx(2)) + sig;
    variance_sum(idx(1):idx(2)) = variance_sum(idx(1):idx(2)) + variance;

end

signal_sum = reshape(signal_sum, size(npix));
variance_sum = reshape(variance_sum, size(npix));

mean_signal = signal_sum./npix;
mean_variance = variance_sum./npix.^2;

% Convert NaNs to zeros (bins where we divide by zero have no pixel contributions)
nopix = (npix(:) == 0);
mean_signal(nopix) = 0;
mean_variance(nopix) = 0;
