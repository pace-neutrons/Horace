function obj = put_bytes(obj, to_write)
%PUT_BYTES Write the given array to the sqw file as single
%
BYTES_IN_SINGLE = 4;
DTYPE = 'float32';

block_size = get(hor_config, 'mem_chunk_size');
nvals_in_block = floor(block_size/BYTES_IN_SINGLE);

for chunk_num = 1:nvals_in_block:numel(to_write)
    istart = chunk_num;
    iend = min(chunk_num + nvals_in_block - 1, numel(to_write));
    fwrite(obj.file_id_, to_write(istart:iend), DTYPE);
    check_error_report_fail_( ...
        obj, ...
        sprintf( ...
            ['Error writing array data, indices from: %d to: %d in the ' ...
             'range from: %d to: %d.'], istart, iend, 1, numel(to_write) ...
        ) ...
    );
end
