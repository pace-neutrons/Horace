function  obj = put_bindata_in_file_(obj,fid,bindata)
%PUT_BINDATA_IN_FILE_ store array of bytes into opened binary file
%
% Inputs:
% fid      -- opened file handle
% bindata  -- array of bytes to store on hdd
%
obj.move_to_position(fid);
%
fwrite(fid,bindata,"uint8");
%
obj.check_write_error(fid);