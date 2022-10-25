function [mean_signal, mean_variance] = compute_bin_data_matlab_(obj, npix)
% Compute bin mean signal and variance using matlab routines
%
% See compute_bin_data for algorithm details
%
if isempty(obj)
    mean_signal = [];
    mean_variance = [];
    return
end

npix_shape = size(npix);

% First argument in accumarray must be a column vector, because pixel signal
% (and variance) is always a row vector
accum_indices = repelem(1:numel(npix), npix(:))';

% We need to set the increment size in the accumarray call or it will
% ignore trailing zeros on the npix chunk. Meaning the increment will be a
% different length to the chunk of the image we're updating
img_signal_sum = accumarray(accum_indices, obj.signal, [numel(npix), 1]);
img_variance_sum = accumarray(accum_indices, obj.variance, [numel(npix), 1]);

img_signal_sum = reshape(img_signal_sum, npix_shape);
img_variance_sum = reshape(img_variance_sum, npix_shape);

[mean_signal,mean_variance] = normalize_signal(img_signal_sum,img_variance_sum,npix);
