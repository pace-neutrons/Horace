function [mean_signal, mean_variance,std_deviation] = compute_bin_data_matlab_( ...
    obj, npix,pix_idx,calc_mean_var,calc_var_from_signal)
% Compute bin mean signal and variance using matlab routines
%
% See compute_bin_data for algorithm details
%
if obj.num_pixels == 0
    mean_signal  = [];
    mean_variance = [];
    std_deviation = [];
    return
end

if isempty(pix_idx)
    signal = obj.signal;
    if ~calc_var_from_signal && calc_mean_var
        variance = obj.variance;
    end
else
    if calc_var_from_signal
        signal = obj.get_pixels(pix_idx,'signal','-raw_data');
    else
        sig_var = obj.get_pixels(pix_idx,'sig_var','-raw_data');
        signal   = sig_var(1,:);
        variance = sig_var(2,:);
    end
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
mean_signal    = img_signal_sum(:)./npix(:);
if ~calc_mean_var
    mean_signal(no_pix)   = 0;
    mean_signal           = reshape(mean_signal, npix_shape);    
    mean_variance = [];
    std_deviation = [];    
    return;
end

if calc_var_from_signal
    std_deviation=(signal - replicate_array(mean_signal,npix(:))').^2;    % square of deviations
else
    std_deviation = variance;
end
img_variance_sum = accumarray(accum_indices, std_deviation, [numel(npix), 1]);
mean_signal      = reshape(mean_signal, npix_shape);
img_variance_sum = reshape(img_variance_sum, npix_shape);
mean_variance    = img_variance_sum./npix.^2;


% By convention, signal and error are zero if no pixels contribute to bin
mean_signal(no_pix)   = 0;
mean_variance(no_pix) = 0;

