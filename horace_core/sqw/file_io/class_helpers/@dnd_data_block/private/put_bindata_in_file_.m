function obj = put_bindata_in_file_(obj,fid,obj_data)
% Overloaded: -- store data containing in dnd_data_block class
% into binary file
%
% Inputs:
% fid      -- opened file handle
% obj_data -- full instance of dnd_data_block class
%
% Returns:
% obj      -- unchanged
% Eroror: HORACE:data_block:io_error is thrhown in case of
%         problem with writing data fields

obj.move_to_position(fid)
head_data = uint32([obj_data.dimensions,obj_data.data_size]);
fwrite(fid,head_data,'uint32');
obj.check_write_error(fid,'header');
%
fwrite(fid,double(obj_data.sig(:)),'double');
obj.check_write_error(fid,'signal');
%
fwrite(fid,double(obj_data.err(:)),'double');
obj.check_write_error(fid,'error');
%
fwrite(fid,uint64(obj_data.npix(:)),'uint64');
obj.check_write_error(fid,'npixel');
