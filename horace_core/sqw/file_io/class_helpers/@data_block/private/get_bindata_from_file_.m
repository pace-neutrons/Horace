function  bindata = get_bindata_from_file_(obj,fid)
%GET_BINDATA_FROM_FILE_ read array of bytes from opened binary file
%
% Inputs:
% fid      -- opened file handle
%
% Outputs:
% bindata  -- unit8 array of the data read from file.
%
% Eroror: HORACE:data_block:io_error is thrhown in case of problem with
%         redading data files

%
obj.move_to_position(fid);

bindata = fread(fid,obj.size,"*uint8");

obj.check_read_error(fid)
