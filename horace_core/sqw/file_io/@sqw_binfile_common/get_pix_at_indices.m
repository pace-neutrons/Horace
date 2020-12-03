function pix = get_pix_at_indices(obj, indices)
%GET_PIX_AT_INDICES Read pixels from file at the given indices.
% The "indices" array must be monotonically increasing.
%

if ~obj.is_activated('read')
    obj = obj.activate('read');
end

NUM_BYTES_IN_FLOAT = 4;
PIXEL_SIZE = NUM_BYTES_IN_FLOAT*PixelData.DEFAULT_NUM_PIX_FIELDS;  % bytes

[read_sizes, seek_sizes] = get_read_and_seek_sizes(indices(:)');

% Pre-allocate output array
pix = zeros(PixelData.DEFAULT_NUM_PIX_FIELDS, sum(read_sizes));

% Position file reader at start of pixel array
do_fseek(obj.file_id_, obj.pix_pos_, 'bof');

num_pix_read = 0;
for block_num = 1:numel(read_sizes)
    do_fseek(obj.file_id_, seek_sizes(block_num)*PIXEL_SIZE, 'cof');

    out_pix_start = num_pix_read + 1;
    out_pix_end = out_pix_start + read_sizes(block_num) - 1;
    pix(:, out_pix_start:out_pix_end) = ...
        do_fread(obj.file_id_, read_sizes(block_num));

    num_pix_read = num_pix_read + read_sizes(block_num);
end

end


% -----------------------------------------------------------------------------
function [read_sizes, seek_sizes] = get_read_and_seek_sizes(indices)
    % Get the consecutive read and seek sizes (in terms of no. of pixels)
    % needed to read in the pixels at the given indices.
    %
    %  >> indices = [3:7, 10:15, 40:41]
    %      -> read_sizes = [5, 5, 1]
    %      -> seek_sizes = [2, 2, 24]
    % For this example, we need to seek 2 pixels, and then read 4 in order to
    % read the 3:4 block of pixels. Then we seek 2 and read 5 to read in the
    % 10:15 block, and so on.

    % Get the difference between neighboring array elements, a difference of
    % more than one suggests we should seek by that many pixels, consecutive 1s
    % means we read as many pixels as there are 1s.
    ind_diff = diff(indices);
    seek_sizes = [indices(1), ind_diff(ind_diff > 1)] - 1;

    % The read blocks end where we find we need to start seeking
    read_ends = [indices(ind_diff ~= 1), indices(end)];
    % The read blocks start where the last seek blocks end
    read_starts = [seek_sizes(1), seek_sizes(2:end) + read_ends(1:(end - 1))];
    read_sizes = read_ends - read_starts;
end


function do_fseek(fid, offset, origin)
    ok = fseek(fid, offset, origin);
    if ok ~= 0
        [mess, ~] = ferror(fid);
        error('SQW_BINFILE_COMMON:get_pix_at_indices', ...
              'Cannot move to requested position in file:\n  %s', ...
              mess);
    end
end


function pix = do_fread(fid, num_pix)
    pix = fread(fid, [PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix], 'float32');
    [mess, ok] = ferror(fid);
    if ok ~= 0
        error('SQW_BINFILE_COMMON:get_pix_at_indices', ...
              'Cannot read requested range in file:\n  %s', ...
              mess);
    end
end
