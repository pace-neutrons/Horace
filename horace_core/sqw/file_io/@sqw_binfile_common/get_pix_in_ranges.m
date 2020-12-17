function pix = get_pix_in_ranges(obj, pix_starts, pix_ends)
%%GET_PIX_IN_RANGES read pixels in the specified ranges
%

NUM_BYTES_IN_FLOAT = 4;
PIXEL_SIZE = NUM_BYTES_IN_FLOAT*PixelData.DEFAULT_NUM_PIX_FIELDS;  % bytes

% Position file reader at start of pixel array
first_seek_pos = obj.pix_pos_ + (pix_starts(1) - 1)*PIXEL_SIZE;
do_fseek(obj.file_id_, first_seek_pos, 'bof');

blocks = cell(1, numel(pix_starts));
for i = 1:numel(pix_starts)
    num_pix_to_read = pix_ends(i) - pix_starts(i) + 1;
    read_size = [PixelData.DEFAULT_NUM_PIX_FIELDS, num_pix_to_read];
    blocks{i} = fread(obj.file_id_, read_size, 'float32');

    try
        seek_size = (pix_starts(i + 1) - pix_ends(i) - 1)*PIXEL_SIZE;
    catch ME
        if strcmpi(ME.identifier, 'MATLAB:badsubscript')
            break
        end
    end
    do_fseek(obj.file_id_, seek_size, 'cof');
end
pix = [blocks{:}];
