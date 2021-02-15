function obj = put_bytes(obj, to_write)
%PUT_BYTES Write the given array to the sqw file as single
%
BYTES_IN_SINGLE = 4;
DTYPE = 'float32';

block_size = get(hor_config, 'mem_chunk_size');
nbytes_to_write = BYTES_IN_SINGLE*numel(to_write);

if nbytes_to_write <= block_size
    fwrite(obj.file_id_,to_write,DTYPE);
    check_error_report_fail_(obj,'Error writing array data.');
else
    for chunk_num = 1:block_size:nbytes_to_write
        istart = chunk_num;
        iend = min(chunk_num + block_size - 1, nbytes_to_write);
        fwrite(obj.file_id_, to_write(istart:iend), DTYPE);
        check_error_report_fail_( ...
            obj, ...
            sprintf( ...
                ['Error writing array data, bytes from: %d to: %d in the ' ...
                 'range from: %d to: %d.'], istart, iend, 1, nbytes_to_write ...
            ) ...
        );
    end
end
