function [mean_signal, mean_variance,std_deviations] = compute_bin_data_( ...
    obj, npix,pix_idx,calc_variance,calc_signal_msd)
% Compute the mean signal and variance given the number of contributing
% pixels for each bin
% Returns empty arrays if obj contains no pixels.
%
%   >> [mean_signal, mean_variance,std_deviations] = compute_bin_data(obj, npix)
%
% Input
% -----
% npix   The number of contributing pixels to each bin of the image
%
% Output
% ------
% mean_signal     The average signal for each image bin.
%                 size(mean_signal) = size(npix)
% mean_variance   The average variance for each image bin.
%                 size(mean_variance) = size(npix)
%

if isempty(pix_idx)
    signal = obj.signal;
    if ~calc_signal_msd && calc_variance
        variance = obj.variance;
    else
        variance = [];
    end
else
    if calc_signal_msd
        signal = obj.get_pixels(pix_idx,'signal','-raw_data');
        variance=[];
    else
        sig_var = obj.get_pixels(pix_idx,'sig_var','-raw_data');
        signal   = sig_var(1,:);
        variance = sig_var(2,:);
    end
end

if calc_signal_msd
    [mean_signal, mean_variance,std_deviations] = ...
        compute_bin_data(npix,signal,variance);
else
    std_deviations = [];
    if calc_variance
        [mean_signal, mean_variance] = ...
            compute_bin_data(npix,signal,variance);
    else
        mean_signal = ...
            compute_bin_data(npix,signal,variance);
        mean_variance = [];
    end
end
