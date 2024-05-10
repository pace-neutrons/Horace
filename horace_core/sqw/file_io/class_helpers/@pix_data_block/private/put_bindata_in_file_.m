function obj = put_bindata_in_file_(obj,fid,obj_data)
% Overloaded: -- store data containing in pix_data_block class
% into binary file
%
% Inputs:
% fid      -- opened file handle
% obj_data -- full instance of pix_data_block class
%
% Returns:
% obj      -- unchanged
% Eroror: HORACE:data_block:io_error is thrhown in case of
%         problem with writing data fields

obj.move_to_position(fid)
n_rows = uint32(obj_data.n_rows);
fwrite(fid,n_rows,'uint32');
obj.check_write_error(fid,'num pix rows');
%
npix  = uint64(obj_data.npix);
fwrite(fid,npix,'uint64');
obj.check_write_error(fid,'num_pixels');
%
if isnumeric(obj_data.data)&&~isempty(obj_data.data)
    obj.move_to_position(fid,obj.pix_position);

    block_size = config_store.instance().get_value('hor_config','mem_chunk_size');
    % apparently faster then writing whole large array and does not crash
    % some Linux FS drivers.
    n_blocks = npix/block_size;
    data  = obj_data.data;
    for istart=1:block_size:npix
        iend  = min(istart+block_size-1,npix);
        block = single(data(:,istart:iend));
        fwrite(fid,block(:),'float32');
        obj.check_write_error(fid, ...
            sprintf('writing pixel data block %d out of %g',istart,n_blocks));
    end

end
%
