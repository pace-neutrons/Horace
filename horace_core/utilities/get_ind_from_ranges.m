function out = get_ind_from_ranges(range_starts, block_sizes)
% Get an array of indexes fom the arrays, defining the initial indexes 
% and the size of the continuous blocks of intexes
% e.g.
%   >> range_starts = [1, 15, 12]
%   >> block_sizes = [4, 3, 3]
%   >> get_ind_from_ranges(range_starts, block_sizes)
%       ans = [1; 2; 3; 4; 15; 16; 17; 12; 13; 14]

% Ensure the vectors are 1xN so concatenation below works
if length(range_starts) > 1 && size(range_starts, 1) ~= 1
    range_starts = range_starts(:)';
    block_sizes  = block_sizes(:)';
    %range_ends = range_ends(:).';
end

% Find the indexes of the boundaries of each range
range_boundary_idxs = cumsum([1, block_sizes]);
range_ends  = range_starts+block_sizes-1;
% Generate vector of ones with length equal to output vector length
value_diffs = ones(range_boundary_idxs(end) - 1, 1);
% Insert size of the difference between boundaries in each boundary index
value_diffs(range_boundary_idxs(1:end - 1)) = ...
    [range_starts(1),range_starts(2:end) - range_ends(1:end - 1)];
% Take the cumulative sum
out = cumsum(value_diffs);
end
