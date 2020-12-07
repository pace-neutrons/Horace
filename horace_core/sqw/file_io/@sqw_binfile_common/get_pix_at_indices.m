function pix = get_pix_at_indices(obj, indices)
%GET_PIX_AT_INDICES Read pixels from file at the given pixel indices.
% The "indices" array must contain integers greater than 0 and be monotonically
% increasing.
%
if indices(end) > obj.npixels
    error('SQW_BINFILE_COMMON:get_pix_at_indices', ...
          ['Cannot retrieve given pixel indices. ' ...
           'Maximum index (%i) greater than number of pixels (%i).'], ...
           indices(end), obj.npixels);
end

if ~obj.is_activated('read')
    obj = obj.activate('read');
end

NUM_BYTES_IN_FLOAT = 4;
PIXEL_SIZE = NUM_BYTES_IN_FLOAT*PixelData.DEFAULT_NUM_PIX_FIELDS;  % bytes

[read_sizes, seek_sizes] = get_read_and_seek_sizes(indices(:)');

% Pre-allocate output array
pix = zeros(PixelData.DEFAULT_NUM_PIX_FIELDS, numel(indices));

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
