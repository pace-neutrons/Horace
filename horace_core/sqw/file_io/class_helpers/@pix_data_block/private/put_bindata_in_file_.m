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
    fwrite(fid,single(obj_data.data(:)),'single');
    obj.check_write_error(fid,'pixel data');
end
%
