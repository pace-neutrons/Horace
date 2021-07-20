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

obj.move_to_first_page();
npix_shape = size(npix);

img_signal_sum = zeros(1, numel(npix));
img_variance_sum = zeros(1, numel(npix));
[npix_chunks, idxs] = split_vector_fixed_sum(npix(:), obj.base_page_size);

for i = 1:numel(npix_chunks)
    npix_chunk = npix_chunks{i};
    idx = idxs(:, i);

    % First argument in accumarray must be a column vector, because pixel signal
    % (and variance) is always a row vector
    accum_indices = make_column(repelem(1:numel(npix_chunk), npix_chunk));
    increment_size = [idx(2) - idx(1) + 1, 1];

    % We need to set the increment size in the accumarray call or it will
    % ignore trailing zeros on the npix chunk. Meaning the increment will be a
    % different length to the chunk of the image we're updating

    sig_increment = accumarray(accum_indices, obj.signal, increment_size);
    img_signal_sum(idx(1):idx(2)) = img_signal_sum(idx(1):idx(2)) + sig_increment';

    var_increment = accumarray(accum_indices, obj.variance, increment_size);
    img_variance_sum(idx(1):idx(2)) = img_variance_sum(idx(1):idx(2)) + var_increment';

    if obj.has_more()
        obj.advance();
    else
        break
    end
end
img_signal_sum = reshape(img_signal_sum, npix_shape);
img_variance_sum = reshape(img_variance_sum, npix_shape);

[mean_signal,mean_variance] = normalize_signal(img_signal_sum,img_variance_sum,npix);

end

