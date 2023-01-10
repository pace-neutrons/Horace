function dnd_data_obj = get_bindata_from_file_(obj,fid)
% read information about dnd_data_block from opened binary file
% and recover the instance of dnd_data_block class
%
% Inputs:
% fid      -- opened file handle
%
% Returns:
% dnd_data_obj
%          -- instance of dnd_data read from file.
%
% Eroror: HORACE:data_block:io_error is thrhown in case of
%         problem with redading data fields
obj.move_to_position(fid);
%
n_dims = fread(fid,1,'uint32');
data_size = fread(fid,n_dims,'uint32');
obj.check_read_error(fid,'header');
%
n_elements = prod(data_size);
sig = fread(fid,n_elements,'*double');
obj.check_read_error(fid,'signal');
%
err = fread(fid,n_elements,'*double');
obj.check_read_error(fid,'error');
%
npix = fread(fid,n_elements,'*uint64');
obj.check_read_error(fid,'npixel');
%
dnd_data_obj = dnd_data(reshape(sig,data_size'), ...
    reshape(err,data_size'),reshape(npix,data_size'));
