function [mean_signal, mean_variance,signal_msd] = compute_bin_data( ...
    npix,signal,variance,no_normalization)
% Compute the mean signal and variance given the number of contributing
% pixels for each bin
% Returns empty arrays if obj contains no pixels.
%
%   >> [mean_signal, mean_variance,std_deviations] = compute_bin_data(npix,signal,variance)
%   >> [mean_signal, mean_variance,std_deviations] = compute_bin_data(npix,signal,variance,no_normalization)
%
% Input
% -----
% npix      The number of contributing pixels to each bin of the plot axes
% signal    The signal array, to calculate binning for
%
% Optional:
% variance  The variance array to calculate binning
%
% no_normalization -- if present and true, do not normalize signal and
%            variance by npix to calculate proper averages.
%
% Output
% ------
% mean_signal     The average signal for each bin.
%                 size(mean_signal) = size(npix)
% Optional:
%
% mean_variance   The average variance for each bin.
%                 size(mean_variance) = size(npix)
%
% signal_msd      If mean_variance is calculated from signal,
%                 signal_std contans the mean square deviation of each
%                 element of signal arry in a bin from its mean value in
%                 this bin. If variance is present, it returned in signal_std
%
%
if nargin<3
    variance = [];
end
if nargin<4
    normalize  = true;
else
    normalize  = ~no_normalization;
end
if nargout > 1
    calc_variance= true;
else
    calc_variance= false;
end
if nargout > 2
    calc_signal_msd = true;
else
    calc_signal_msd = false;
end
if sum(npix(:)) ~= numel(signal)
    error('HORACE:utilities:invalid_argument', ...
        'number of elements in signal array (%s) have to be equal to the total npix (%d)', ...
        numel(signal),sum(npix(:)));
end
if ~isempty(variance) && numel(signal) ~= numel(variance)
    error('HORACE:utilities:invalid_argument', ...
        'If variance provided, number of elements in signal array (%s) have to be equal to the number of elements in variance array (%d)', ...
        numel(signal),numel(variance))
end


% Re #1295 Mex disabled -- fix and enable when necessary
use_mex = false;
if use_mex
    try
        [mean_signal, mean_variance,signal_msd] = ...
            compute_bin_data_mex_(obj, npix,pix_idx,mean_var,average_signal);
    catch ME
        if hor_config().force_mex_if_use_mex
            rethrow(ME);
        end
        use_mex = false;
        if log_level>0
            warning('SQW:mex_code_problem', ...
                ['sqw:recompute_bin_data -- c-code problem: ' ...
                '%s\n Trying to use Matlab'], ME.message);
        end
    end
end

if ~use_mex
    [mean_signal, mean_variance,signal_msd] = ...
        compute_bin_data_matlab_(npix,signal,variance,calc_variance,calc_signal_msd,normalize);
end
