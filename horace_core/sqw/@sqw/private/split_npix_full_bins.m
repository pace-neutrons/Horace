function [npix_chunks, idxs] = split_npix_full_bins(npix, page_size, num_pix, npix_cum_sum)
%SPLIT_NPIX_FULL_BINS Split the given array of counts such that the sum of each
%  sub-array has a maximum of page_size.
%
% The npix counts are not split across bin boundaries - i.e. each sub-array
% contains only full bins. If a value in npix is greater than page_size, then
% that value will comprise its own sub-array.
%
% Input:
% ------
% npix          An array of integers (usually sqw.data.npix)
% page_size     An integer specifying the maximum sum for each sub-array
% num_pix       The sum of all npix values, equal to sum(npix(:)).
% npix_cum_sum  The cumulative sum of the given npix array. Should be equal to
%               cumsum(npix(:)).
%
% Output:
% -------
% npix_chunks  Cell array of vectors. Concatenation of these arrays will be
%              equal to a flattened version the inputted npix array, i.e.
%              npix(:).
% idxs         The indices at which the input npix array was "split". Has size
%              [2, n], where n is numel(npix_chunks). Each idxs(:, i) is the
%              upper and lower index into npix of npix_chunks{i}.
%
% Example:
% --------
% >> npix = [3, 2, 0, 6, 0, 5, 3, 1, 1, 4, 2, 3, 0];
% >> page_size = 11;
% >> [chunks, idxs] = split_npix_full_bins(npix, page_size)
%   chunks =
%       { [3, 2, 0, 6, 0], [5, 3, 1, 1], [4, 2, 3, 0] }
%   idxs =
%       1     6    10
%       5     9    13
%
if num_pix < page_size
    % Only one page of data, return only chunk
    npix_chunks = {npix};
    idxs = [1; numel(npix)];
    return
end

num_pages = ceil(num_pix/page_size);

npix_chunks = cell(1, num_pages);
idxs = zeros(2, num_pages);
end_idx = 0;
for iter = 1:num_pages
    start_idx = end_idx + 1;
    % Find first index where cumulative sum is greater than page_size
    end_idx = ...
        (start_idx - 1) + find(npix_cum_sum(start_idx:end) > page_size, 1) - 1;
    if isempty(end_idx)
        % If no elements of cumulative sum > page_size, this is the final chunk
        end_idx = numel(npix_cum_sum);
    end

    if start_idx > end_idx
        % Happens where bin size > page size
        end_idx = start_idx;
    end

    npix_chunks{iter} = npix(start_idx:end_idx);
    idxs(:, iter) = [start_idx, end_idx];

    % Decrement the cumulative sum with the number of values we've allocated
    npix_cum_sum = npix_cum_sum - npix_cum_sum(end_idx);
end
