function [read_sizes, seek_sizes] = get_read_and_seek_sizes(indices)
%GET_READ_AND_SEEK_SIZES Get the consecutive read and seek sizes needed to read
% bytes at the given indices
%
%  >> [read_sizes, seek_sizes] = get_read_and_seek_sizes([1:10, 15:21])
%
%  >> indices = [3:7, 10:15, 40:41]
%      -> read_sizes = [5, 6, 2]
%      -> seek_sizes = [2, 2, 24]
% For this example, we need to seek 2 bytes, and then read 5 in order to
% read bytes 3-7. Then we seek 2 (skipping over bytes 8 and 9) and read 5
% more bytes to get 10-15, and so on.
%
% This can be used to read ranges of bytes within a file:
%   >> data = cell(1, numel(read_sizes));
%   >> fid = fopen('mybinary_file', 'r');
%   >> for i = 1:numel(read_sizes)
%          do_fseek(fid, seek_sizes(i), 'cof');
%          data{i} = fread(fid, read_sizes(i));
%      end
%
if isempty(indices)
    read_sizes = [];
    seek_sizes = [];
    return
end

validateattributes(indices, {'numeric'}, {'positive', 'integer'})

% Get the difference between neighboring array elements, a difference of
% more than one suggests we should seek by that many bytes, consecutive 1s
% means we read as many bytes as there are 1s.
ind_diff = diff(indices);
seek_sizes = [indices(1), ind_diff(ind_diff ~= 1)] - 1;

% The read blocks end where we find we need to start seeking
read_ends = [indices(ind_diff ~= 1), indices(end)];
% The read blocks start where the last seek blocks end
read_starts = [seek_sizes(1), seek_sizes(2:end) + read_ends(1:(end - 1))];
read_sizes = read_ends - read_starts;

end
