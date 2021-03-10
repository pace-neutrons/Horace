function [chunks, idxs] = split_vector(vector, max_chunk_sum)
%SPLIT_VECTOR Split the given vector into a set of sub-vectors such that the
% sum of each sub-vector has a maximum of max_chunk_sum, or the sub-vector has length
% 1.
%
% If a value in `vector` is greater than max_chunk_sum, then that value will comprise
% its own sub-vector.
%
% Input:
% ------
% vector       A vector of non-negative values.
% max_chunk_sum      A positive value specifying the maximum sum for each sub-vector.
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
% >> max_chunk_sum = 11;
% >> [chunks, idxs] = split_vector(vector, max_chunk_sum)
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
validateattributes(max_chunk_sum, {'numeric'}, {'scalar', 'positive'});

% Maximum number of chunks is the length of the input vector - where every
% value of 'vector' >= 'max_chunk_sum'
max_num_chunks = numel(vector);

cumulative_sum = cumsum(vector);
if (max_num_chunks == 1) || (ceil(cumulative_sum(end)/max_chunk_sum) == 1)
    % Only one chunk of data, return it
    chunks = {vector};
    idxs = [1; numel(vector)];
    return
end

chunks = cell(1, max_num_chunks);
idxs = zeros(2, max_num_chunks);
chunk_num = 0;
end_idx = 0;
while end_idx < max_num_chunks
    chunk_num = chunk_num + 1;

    start_idx = end_idx + 1;
    % Find first index where cumulative sum is greater than max_chunk_sum
    end_idx = end_idx + find(cumulative_sum(start_idx:end) > max_chunk_sum, 1) - 1;
    if isempty(end_idx)
        % If no elements of cumulative sum > max_chunk_sum, this is the final chunk
        end_idx = numel(cumulative_sum);
    end

    if start_idx > end_idx
        % If a vector value is greater than max_sum, then end_idx will not have
        % been increased on this iteration, whereas start_idx is always
        % end_idx + 1. Setting end_idx to match start_idx in this case
        % means the chunk assigned on this iteration only contains the next
        % vector value.
        end_idx = start_idx;
    end

    chunks{chunk_num} = vector(start_idx:end_idx);
    idxs(:, chunk_num) = [start_idx, end_idx];

    % Increment max_chunk_sum by the sum of the values we allocated this iteration.
    % This is so, on the next iteration, the find call gets the next set of
    % indices such that sum(chunk) <= max_chunk_sum.
    if start_idx > 1
        last_cumsum_end = cumulative_sum(start_idx - 1);
    else
        last_cumsum_end = 0;
    end
    max_chunk_sum = max_chunk_sum + cumulative_sum(end_idx) - last_cumsum_end;
end

% Crop unassigned parts of output arrays
chunks = chunks(1:chunk_num);
idxs = idxs(:, 1:chunk_num);
