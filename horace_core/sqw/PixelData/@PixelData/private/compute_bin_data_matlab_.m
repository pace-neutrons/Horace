function [mean_signal, mean_variance] = compute_bin_data_matlab_(obj, npix, log_level)
% Compute bin mean signal and variance using matlab routines
%
% See compute_bin_data for algorithm details
%
nbin = numel(npix);

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
base_page_size = min(obj.max_page_size_, obj.num_pixels);

signal_sum = zeros(size(npix));
variance_sum = zeros(size(npix));
while true
    start_idx = (obj.page_number_ - 1)*base_page_size + 1;
    end_idx = min(start_idx + base_page_size - 1, obj.num_pixels);
    signal_sum = signal_sum + accumarray(ind(start_idx:end_idx), obj.signal, [nbin, 1]);
    variance_sum = variance_sum + accumarray(ind(start_idx:end_idx), obj.variance, [nbin, 1]);

    if obj.has_more()
        obj.advance();
    else
        break;
    end
end
mean_signal = signal_sum ./ npix(:);
mean_signal = reshape(mean_signal, size(npix));
mean_variance = variance_sum ./ (npix(:).^2);
mean_variance = reshape(mean_variance, size(npix));

nopix = (npix(:) == 0);
mean_signal(nopix) = 0;
mean_variance(nopix) = 0;
