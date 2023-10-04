function [mean_signal, mean_variance] = compute_bin_data_mex_(obj, npix,pix_idx,average_signal n_threads)
% Compute bin mean signal and variance using mex library
%
% See compute_bin_data for algorithm details
%

% CURRENTLY DISABLED: See Re #1295 to fix this.
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

[signal_sum, variance_sum] = compute_pix_sums_c(npix, obj.data, n_threads);
signal_sum = reshape(signal_sum, size(npix));
variance_sum = reshape(variance_sum, size(npix));

mean_signal = signal_sum./npix;
mean_variance = variance_sum./npix.^2;

% Convert NaNs to zeros (bins where we divide by zero have no pixel contributions)
nopix = (npix(:) == 0);
mean_signal(nopix) = 0;
mean_variance(nopix) = 0;
