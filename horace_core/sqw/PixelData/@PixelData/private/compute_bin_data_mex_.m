function [mean_signal, mean_variance] = compute_bin_data_mex_(obj, npix, n_threads)
% Compute bin mean signal and variance using mex library
%
% See compute_bin_data for algorithm details
%

if isempty(obj)
    return;
end
[mean_signal, mean_variance] = recompute_bin_data_c(npix, obj.data, n_threads);
