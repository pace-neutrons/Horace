function [chunks, idxs] = split_vector(vector, sum_max)
%SPLIT_VECTOR Split the given array of such that the sum of each sub-array has
% a maximum of sum_max or has length 1.
%
% If a value in vector is greater than sum_max, then that value will
% comprise its own sub-array.
%
% Input:
% ------
% vector       A vector of non-negative values.
% sum_max      A positive value specifying the maximum sum for each sub-array.
%
% Output:
% -------
% chunks       Cell array of vectors. Concatenation of these arrays will be
%              equal to the input vector.
% idxs         The indices at which the input vector was "split". Has size
%              [2, n], where n is numel(chunks). Each idxs(:, i) is the
%              upper and lower index into vector of chunks{i}.
%
% Example:
% --------
% >> vector = [3, 2, 0, 6, 0, 5, 3, 1, 1, 24, 4, 2, 3, 0];
% >> sum_max = 11;
% >> [chunks, idxs] = split_vector(vector, sum_max)
%   chunks =
%       { [3, 2, 0, 6, 0], [5, 3, 1, 1], [24], [4, 2, 3, 0] }
%   idxs =
%       1     6    10    11
%       5     9    10    14
%
if isempty(vector)
    chunks = {};
    idxs = zeros(2, 0);
    return;
end

validateattributes(vector, {'numeric'}, {'vector', 'nonnegative'});
validateattributes(sum_max, {'numeric'}, {'scalar', 'positive'});

cumulative_sum = cumsum(vector);
max_chunks = ceil(cumulative_sum(end)/sum_max);

if max_chunks == 1
    % Only one chunk of data, return it
    chunks = {vector};
    idxs = [1; numel(vector)];
    return
end

chunks = cell(1, max_chunks);
idxs = zeros(2, max_chunks);
iter = 1;
end_idx = 0;
while end_idx < numel(vector)
    start_idx = end_idx + 1;
    % Find first index where cumulative sum is greater than sum_max
    end_idx = ...
        (start_idx - 1) + find(cumulative_sum(start_idx:end) > sum_max, 1) - 1;
    if isempty(end_idx)
        % If no elements of cumulative sum > sum_max, this is the final chunk
        end_idx = numel(cumulative_sum);
    end

    if start_idx > end_idx
        % Happens where count > max_count
        end_idx = start_idx;
    end

    chunks{iter} = vector(start_idx:end_idx);
    idxs(:, iter) = [start_idx, end_idx];

    % Decrement the cumulative sum with the number of values we've allocated
    cumulative_sum = cumulative_sum - cumulative_sum(end_idx);
    iter = iter + 1;
end

chunks = chunks(1:iter - 1);
idxs = idxs(:, 1:iter - 1);
