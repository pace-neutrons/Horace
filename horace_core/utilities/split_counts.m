function [chunks, idxs] = split_counts(counts, max_counts, varargin)
%SPLIT_COUNTS_VECTOR Split the given array of counts such that the sum of each
%  sub-array has a maximum of max_counts or has length 1.
%
% The counts counts are not split across bin boundaries - i.e. each sub-array
% contains only full bins. If a value in counts is greater than max_counts, then
% that value will comprise its own sub-array.
%
% Input:
% ------
% counts             A vector of positive integers.
% max_counts         An integer specifying the maximum sum for each sub-array.
% total_counts       The sum of all counts values, equal to sum(counts).
%                    [optional]
% cumulative_counts  The cumulative sum of the given counts array.
%                    Should be equal to cumsum(counts). [optional]
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
% >> [chunks, idxs] = split_counts(counts, max_counts, sum(counts), cumsum(counts))
%   chunks =
%       { [3, 2, 0, 6, 0], [5, 3, 1, 1], [24], [4, 2, 3, 0] }
%   idxs =
%       1     6    10    11
%       5     9    10    14
%
if isempty(counts)
    chunks = {};
    idxs = [];
    return;
end

[counts, max_counts, total_counts, cumulative_counts] = ...
    parse_args(counts, max_counts, varargin{:});

if total_counts <= max_counts
    % Only one chunk of data, return it
    chunks = {counts};
    idxs = [1; numel(counts)];
    return
end

max_chunks = ceil(total_counts/max_counts);

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

end


% -----------------------------------------------------------------------------
function [counts, max_counts, total_counts, cumulative_counts] = parse_args(varargin)
    numeric_vector = @(x) validateattributes(x, {'numeric'}, {'vector'});
    numeric_scalar = @(x) validateattributes(x, {'numeric'}, {'scalar'});

    parser = inputParser();
    parser.addRequired('counts', numeric_vector);
    parser.addRequired('max_counts', numeric_scalar);
    parser.addOptional('total_counts', [], numeric_scalar);
    parser.addOptional('cumulative_counts', [], numeric_vector);
    parser.parse(varargin{:});

    counts = parser.Results.counts;
    max_counts = parser.Results.max_counts;
    cumulative_counts = parser.Results.cumulative_counts;
    if isempty(cumulative_counts)
        cumulative_counts = cumsum(counts);
    end
    total_counts = parser.Results.total_counts;
    if isempty(total_counts)
        total_counts = cumulative_counts(end);
    end
end
