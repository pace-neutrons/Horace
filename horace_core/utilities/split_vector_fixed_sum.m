function [chunks, idxs] = split_vector_fixed_sum(numeric_vector, chunk_sum, cumulative_sum)
%SPLIT_VECTOR_FIXED_SUM Split the given vector into sub-vectors such that each
% sub-vector has sum 'chunk_sum'. If chunk sum does not divide the sum of the
% input vector, the final chunk's sum will be the remainder.
%
% Values in the input vector may be split between chunks.
%
% Input:
% ------
% numeric_vector   A vector of numeric, non-negative, values.
% chunk_sum        A positive value specifying the sum for each sub-vector.
% cumulative_sum   The cumulative sum of 'numeric_vector'. (optional)
%
% Output:
% -------
% chunks   Cell array of vectors.
% idxs     The indices at which the input vector was "split". Has size
%          [2, n], where n is numel(chunks). Each idxs(:, chunk_num) is the
%          lower and upper index into 'numeric_vector' of chunks{chunk_num}.
%
% Example:
% --------
% >> numeric_vector = [3, 2, 6, 0, 5, 3, 1, 0, 1, 24, 4, 2, 3, 0];
% >> chunk_sum = 10;
% >> [chunks, idxs] = split_vector_max_sum(numeric_vector, chunk_sum)
%   chunks =
%       { [3, 2, 5], [1, 0, 5, 3, 1, 0], [1, 9], [10], [5, 4, 1], [1, 3, 0] }
%   idxs =
%       1     4     9    10    10    12
%       4     8    10    10    12    14
%
% >> numeric_vector = [24];
% >> chunk_sum = 10;
%   chunks =
%       { [10], [10], [4] }
%   idxs =
%       1
%       1
%
if isempty(numeric_vector)
    chunks = {};
    idxs = zeros(2, 0);
    return;
end

validateattributes(numeric_vector, {'numeric'}, {'vector', 'nonnegative'});
validateattributes(chunk_sum, {'numeric'}, {'scalar', 'positive'});

if ~exist('cumulative_sum', 'var')
    cumulative_sum = cumsum(numeric_vector);
end
vector_sum = cumulative_sum(end);
num_chunks = ceil(vector_sum/chunk_sum);

chunks = cell(1, num_chunks);
idxs = zeros(2, num_chunks);
end_idx = 1;
allocated = 0;
for chunk_num = 1:num_chunks
    chunk_sum = min(chunk_sum, vector_sum - allocated);

    start_idx = (end_idx - 1) + find(cumulative_sum(end_idx:end) > 0, 1);

    leftover_begin = cumulative_sum(start_idx);

    cumulative_sum = cumulative_sum - chunk_sum;

    end_idx = (start_idx - 1) + find(cumulative_sum(start_idx:end) > 0, 1);

    if isempty(end_idx)
        end_idx = numel(numeric_vector);
    end

    if start_idx == end_idx
        if ~exist('leftover_end', 'var')
            leftover_end = 0;
        end
        chunks{chunk_num} = min(chunk_sum, numeric_vector(start_idx) - leftover_end);
    else
        chunk = [ ...
            leftover_begin, ...
            reshape(numeric_vector(start_idx + 1:end_idx - 1), 1, []), ...
            0 ...
        ];

        leftover_end = chunk_sum - sum(chunk);
        if leftover_end == 0 && chunk_num ~= num_chunks
            chunk = chunk(1:end - 1);
            end_idx = end_idx - 1;
        else
            chunk(end) = leftover_end;
        end
        chunks{chunk_num} = chunk;
    end
    idxs(:, chunk_num) = [start_idx; end_idx];
    allocated = allocated + sum(chunks{chunk_num});
end
