function pix_data_obj = get_bindata_from_file_(obj,fid)
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
%

obj.move_to_position(fid);
%
n_rows = fread(fid,1,'uint32');
obj.check_read_error(fid,'num pix rows');

n_pix = fread(fid,1,'uint64');
obj.check_read_error(fid,'num pixels');
%
pix = fread(fid,[n_rows,n_pix],'single');

pix_data_obj = pix_data(pix);