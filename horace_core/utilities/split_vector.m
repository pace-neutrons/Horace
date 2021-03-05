function [chunks, idxs] = split_vector(vector, sum_max)
%SPLIT_VECTOR Split the given vector into a set of sub-vectors such that the
% sum of each sub-vector has a maximum of sum_max, or the sub-vector has length
% 1.
%
% If a value in `vector` is greater than sum_max, then that value will comprise
% its own sub-vector.
%
% Input:
% ------
% vector       A vector of non-negative values.
% sum_max      A positive value specifying the maximum sum for each sub-vector.
%
% Output:
% -------
% chunks       Cell array of vectors. Concatenation of these vectors will be
%              equal to the input vector.
% idxs         The indices at which the input vector was "split". Has size
%              [2, n], where n is numel(chunks). Each idxs(:, i) is the
%              lower and upper index into 'vector' of chunks{i}.
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
iter = 0;
end_idx = 0;
while end_idx < numel(vector)
    iter = iter + 1;

    start_idx = end_idx + 1;
    % Find first index where cumulative sum is greater than sum_max
    end_idx = end_idx + find(cumulative_sum(start_idx:end) > sum_max, 1) - 1;
    if isempty(end_idx)
        % If no elements of cumulative sum > sum_max, this is the final chunk
        end_idx = numel(cumulative_sum);
    end

    if start_idx > end_idx
        % Happens where vector value > sum_max
        end_idx = start_idx;
    end

    chunks{iter} = vector(start_idx:end_idx);
    idxs(:, iter) = [start_idx, end_idx];

    % Increment sum_max by the sum of the values we allocated this iteration.
    % This is so, on the next iteration, the find call gets the next set of
    % indices such that sum(chunk) <= sum_max.
    if start_idx > 1
        last_cumsum_end = cumulative_sum(start_idx - 1);
    else
        last_cumsum_end = 0;
    end
    sum_max = sum_max + cumulative_sum(end_idx) - last_cumsum_end;
end

chunks = chunks(1:iter);
idxs = idxs(:, 1:iter);
