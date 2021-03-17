function [mean_signal, mean_variance] = compute_bin_data_matlab_(obj, npix, log_level)
% Compute bin mean signal and variance using matlab routines
%
% See compute_bin_data for algorithm details
%
obj.move_to_first_page();
npix_shape = size(npix);

img_signal_sum = zeros(1, numel(npix));
img_variance_sum = zeros(1, numel(npix));
[npix_chunks, idxs] = split_vector_fixed_sum(npix(:), obj.base_page_size);
for i = 1:numel(npix_chunks)
    npix_chunk = npix_chunks{i};
    idx = idxs(:, i);

    % First argument in accumarray must be a column vector, so make input
    % to 'repelem' a column so we get a column out
    accum_indices = repelem(make_column(1:numel(npix_chunk)), npix_chunk);

    % Pixel data is always a row vector, make sure the increment is also
    sig_increment = make_row(accumarray(accum_indices, obj.signal));
    img_signal_sum(idx(1):idx(2)) = img_signal_sum(idx(1):idx(2)) + sig_increment;
    var_increment = make_row(accumarray(accum_indices, obj.variance));
    img_variance_sum(idx(1):idx(2)) = img_variance_sum(idx(1):idx(2)) + var_increment;

    if obj.has_more()
        obj.advance();
    else
        break
    end
end
img_signal_sum = reshape(img_signal_sum, npix_shape);
img_variance_sum = reshape(img_variance_sum, npix_shape);

mean_signal = img_signal_sum./npix;
mean_variance = img_variance_sum./(npix.^2);

% Convert NaNs to zeros (bins where we divide by zero have no pixel contributions)
nopix = (npix == 0);
mean_signal(nopix) = 0;
mean_variance(nopix) = 0;
