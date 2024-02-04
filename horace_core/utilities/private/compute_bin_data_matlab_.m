function [mean_signal, mean_variance,signal_msd] = compute_bin_data_matlab_( ...
    npix,signal,variance,calc_variance,calc_signal_msd,normalize)
% Compute bin mean signal and variance using matlab routines
%
% See compute_bin_data for algorithm details
%
if numel(signal) == 0
    mean_signal  = zeros(size(npix));
    mean_variance = zeros(size(npix));
    signal_msd = [];
    return
end


npix_shape = size(npix);
no_pix = (npix == 0);  % true where no pixels contribute to given bin

% First argument in accumarray must be a column vector, because pixel signal
% (and variance) is always a row vector
accum_indices = repelem(1:numel(npix), npix(:))';

% We need to set the increment size in the accumarray call or it will
% ignore trailing zeros on the npix chunk. Meaning the increment will be a
% different length to the chunk of the image we're updating
img_signal_sum = accumarray(accum_indices,  signal, [numel(npix), 1]);
if normalize
    mean_signal = img_signal_sum(:)./npix(:);    
else
    mean_signal = img_signal_sum(:);
end
if ~calc_variance
    mean_signal(no_pix)   = 0;
    mean_signal           = reshape(mean_signal, npix_shape);
    mean_variance = [];
    signal_msd = [];
    return;
end

if calc_signal_msd && isempty(variance)
    if normalize
        msi = mean_signal;
    else
        msi = mean_signal(:)./npix(:);            
    end
    signal_msd=(signal - replicate_array(msi,npix(:))').^2;    % square of deviations
else
    signal_msd = variance;
end
img_variance_sum = accumarray(accum_indices, signal_msd, [numel(npix), 1]);
mean_signal      = reshape(mean_signal, npix_shape);
img_variance_sum = reshape(img_variance_sum, npix_shape);
if normalize
    mean_variance    = img_variance_sum./npix.^2;
else
    mean_variance    = img_variance_sum;
end


% By convention, signal and error are zero if no pixels contribute to bin
mean_signal(no_pix)   = 0;
mean_variance(no_pix) = 0;

