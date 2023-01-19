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
PIXEL_SIZE = NUM_BYTES_IN_FLOAT*PixelDataBase.DEFAULT_NUM_PIX_FIELDS;  % bytes

[read_sizes, seek_sizes] = get_read_and_seek_sizes(indices(:)');

% Position file reader at start of pixel array
do_fseek(obj.file_id_, obj.pix_pos_, 'bof');

% Assigning pixel blocks to a cell array and combining after appears to be
% marginally faster than pre-allocating a large array and assigning to it
blocks = cell(1, numel(read_sizes));
for block_num = 1:numel(read_sizes)
    do_fseek(obj.file_id_, seek_sizes(block_num)*PIXEL_SIZE, 'cof');
    read_size = [PixelDataBase.DEFAULT_NUM_PIX_FIELDS, read_sizes(block_num)];
    blocks{block_num} = do_fread(obj.file_id_, read_size, 'float32');
end
pix = [blocks{:}];

end
