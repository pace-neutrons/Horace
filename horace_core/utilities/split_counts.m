function [chunks, idxs] = split_counts(counts, max_counts)
%SPLIT_COUNTS Split the given array of counts such that the sum of each
%  sub-array has a maximum of max_counts or has length 1.
%
% The counts counts are not split across bin boundaries - i.e. each sub-array
% contains only full bins. If a value in counts is greater than max_counts, then
% that value will comprise its own sub-array.
%
% Input:
% ------
% counts             A vector of positive values.
% max_counts         An integer specifying the maximum sum for each sub-array.
%
% Output:
% -------
% chunks       Cell array of vectors. Concatenation of these arrays will be
%              equal to a flattened version the inputted counts array, i.e.
%              counts(:).
% idxs         The indices at which the input counts array was "split". Has size
%              [2, n], where n is numel(chunks). Each idxs(:, i) is the
%              upper and lower index into counts of chunks{i}.
%
% Example:
% --------
% >> counts = [3, 2, 0, 6, 0, 5, 3, 1, 1, 24, 4, 2, 3, 0];
% >> max_counts = 11;
% >> [chunks, idxs] = split_counts(counts, max_counts)
%   chunks =
%       { [3, 2, 0, 6, 0], [5, 3, 1, 1], [24], [4, 2, 3, 0] }
%   idxs =
%       1     6    10    11
%       5     9    10    14
%
if isempty(counts)
    chunks = {};
    idxs = zeros(2, 0);
    return;
end

validateattributes(counts, {'numeric'}, {'vector', 'nonnegative'});
validateattributes(max_counts, {'numeric'}, {'scalar', 'positive'});

cumulative_counts = cumsum(counts);
total_counts = cumulative_counts(end);
max_chunks = ceil(total_counts/max_counts);

if max_chunks == 1
    % Only one chunk of data, return it
    chunks = {counts};
    idxs = [1; numel(counts)];
    return
end

chunks = cell(1, max_chunks);
idxs = zeros(2, max_chunks);
iter = 1;
end_idx = 0;
while end_idx < numel(counts)
    start_idx = end_idx + 1;
    % Find first index where cumulative sum is greater than max_counts
    end_idx = ...
        (start_idx - 1) + find(cumulative_counts(start_idx:end) > max_counts, 1) - 1;
    if isempty(end_idx)
        % If no elements of cumulative sum > max_counts, this is the final chunk
        end_idx = numel(cumulative_counts);
    end

    if start_idx > end_idx
        % Happens where bin size > page size
        end_idx = start_idx;
    end

    chunks{iter} = counts(start_idx:end_idx);
    idxs(:, iter) = [start_idx, end_idx];

    % Decrement the cumulative sum with the number of values we've allocated
    cumulative_counts = cumulative_counts - cumulative_counts(end_idx);
    iter = iter + 1;
end

chunks = chunks(1:iter - 1);
idxs = idxs(:, 1:iter - 1);
