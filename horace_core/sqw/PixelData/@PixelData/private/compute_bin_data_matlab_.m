function [mean_signal, mean_variance] = compute_bin_data_matlab_(obj, npix, log_level)
% Compute bin mean signal and variance using matlab routines
%
% See compute_bin_data for algorithm details
%
nbin = numel(npix);
npix_shape = size(npix);

try
    bin_indices = int64(1:nbin);
    npix = reshape(npix, numel(npix), 1);
    allocatable = npix(bin_indices) ~= 0;
    % List of indices of bins for which pixels can be allocated
    bin_indices = bin_indices(allocatable);

    if isempty(bin_indices)
        return;
    end

    ti = arrayfun(@(ind) {int64(ones(npix(ind), 1)) * ind}, bin_indices);
    ind = cat(1, ti{:});
    clear bin_indices ti allocatable;

catch ME
    switch ME.identifier
        case 'MATLAB:nomem'
            clear bin_indices ti allocatable;

            nend = cumsum(npix(:));
            npixtot = nend(end);
            nbeg = nend - npix(:) + 1;
            ind = zeros(npixtot, 1, 'int32');

            if log_level > 0
                warning('SQW:recompute_bin_data', ...
                    'Not enough memory to define bin indexes, running slow loop')
            end

            for i = 1:nbin
                ind(nbeg(i):nend(i)) = i;
            end

            if log_level > 0
                warning('SQW:recompute_bin_data', ' slow loop completed')
            end

        otherwise
            rethrow(ME);
    end
end

obj.move_to_first_page();  % make sure we're at the first page of data

signal_sum = zeros(size(npix));
variance_sum = zeros(size(npix));
end_idx = 1;
while true
    start_idx = end_idx;
    end_idx = start_idx + obj.page_size - 1;
    signal_sum = signal_sum ...
        + accumarray(ind(start_idx:end_idx), obj.signal, [nbin, 1]);
    variance_sum = variance_sum ...
        + accumarray(ind(start_idx:end_idx), obj.variance, [nbin, 1]);

    if obj.has_more()
        obj.advance();
    else
        break;
    end
end
mean_signal = signal_sum ./ npix;
mean_signal = reshape(mean_signal, npix_shape);
mean_variance = variance_sum ./ (npix.^2);
mean_variance = reshape(mean_variance, npix_shape);

% Convert NaNs to zeros (bins where we divide by zero have no pixel contributions)
nopix = (npix(:) == 0);
mean_signal(nopix) = 0;
mean_variance(nopix) = 0;
