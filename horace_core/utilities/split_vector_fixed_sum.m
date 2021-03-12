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
    remaining_sum = vector_sum - allocated;
    chunk_sum = min(chunk_sum, remaining_sum);

    % Find the index of the first value in the input vector that will
    % contribute to the current chunk.
    % This index may contribute its full value, or only part of its value
    if chunk_num == 1
        % For the first iteration, we need >= to catch leading zeros
        start_idx = (end_idx - 1) + find(cumulative_sum(end_idx:end) >= 0, 1);
    else
        % We ignore leading zeros on subsequent iterations as they will have
        % been assigned to the previous chunk
        start_idx = (end_idx - 1) + find(cumulative_sum(end_idx:end) > 0, 1);
    end

    % The start value of the current chunk. This will be non-zero if we didn't
    % assign the end index's full value on the last iteration
    leftover_begin = cumulative_sum(start_idx);

    % Subtract the sum of the values we've allocated this iteration from the
    % cumulative sum. This means the next 'find' call will retrieve the index
    % such that the chunk
    cumulative_sum = cumulative_sum - chunk_sum;

    % Now the cumulative_sum has been decremented, a similar 'find' call to
    % above finds the final index for the this iteration's chunk
    end_idx = (start_idx - 1) + find(cumulative_sum(start_idx:end) > 0, 1);

    if isempty(end_idx)
        % No end index found, so we must be at the end of the vector
        end_idx = numel(numeric_vector);
    end

    if start_idx == end_idx
        % All vector values in single value for this chunk
        if ~exist('leftover_end', 'var')
            leftover_end = 0;
        end
        chunks{chunk_num} = min(chunk_sum, numeric_vector(start_idx) - leftover_end);
    else
        % Build the chunk, leftover begin is the remainder of the end index
        % value, that wasn't assigned in the previous iteration.
        % Add an empty element to the end, which will either be used to hold a
        % part of the end index's value. If there's no remainder on the end
        % index's value, the empty element will be removed
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


% Algorithm run through:

% numeric_vector = [3, 2, 3, 6]
% chunk_sum = 6

% cumulative_sum = [3, 5, 8, 14]
% end_idx = 1

% chunk_num == 1:

% 	start_idx = (end_idx - 1) + find(cumulative_sum(end_idx:end) > 0, 1)
% 		= 1

% 	leftover_begin = cumulative_sum(start_idx)
% 		= 3

% 	cumulative_sum = cumulative_sum - chunk_sum
% 		= [-3, -1, 2, 8]

% 	end_idx = (start_idx - 1) + find(cumulative_sum(start_idx:end) > 0, 1)
% 		= 3

% 	chunk = [ ...
%             leftover_begin, ...
%             reshape(numeric_vector(start_idx + 1:end_idx - 1), 1, []), ...
%             0 ...
%         ];
% 		= [3, 0]

% 	leftover_end = chunk_sum - sum(chunk)
% 		= 3

% 	chunk(end) = 3
% 	chunk
% 		= [3, 3]


% chunk_num == 2:

% 	start_idx = (end_idx - 1) + find(cumulative_sum(end_idx:end) > 0, 1)
% 		= 3

% 	leftover_begin = cumulative_sum(start_idx)
% 		= 2

% 	cumulative_sum = cumulative_sum - chunk_sum
% 		= [-9, -7, -4, 2]

% 	end_idx = (start_idx - 1) + find(cumulative_sum(start_idx:end) > 0, 1)
% 		= 4

% 	chunk = [ ...
% 		leftover_begin, ...
% 		reshape(numeric_vector(start_idx + 1:end_idx - 1), 1, []), ...
% 		0 ...
%     ];
% 		= [2, 0]

% 	leftover_end = chunk_sum - sum(chunk)
% 		= 4

% 	chunk(end) = 4
% 	chunk
% 		= [2, 4]


% chunk_num == 3:  (final chunk)

% 	start_idx = (end_idx - 1) + find(cumulative_sum(end_idx:end) > 0, 1)
% 		= 4

% 	leftover_begin = cumulative_sum(start_idx)
% 		= 2

% 	cumulative_sum = cumulative_sum - chunk_sum
% 		= [-15, -13, -10, -4]

% 	end_idx = (start_idx - 1) + find(cumulative_sum(start_idx:end) > 0, 1)
% 		= []

% 	if isempty(end_idx)
%         end_idx = numel(numeric_vector);
% 			= 4
%     end

% 	if start_idx == end_idx
% 		chunk = min(chunk_sum, numeric_vector(start_idx) - leftover_end);
% 			= 2
% 	end




