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
fseek(fid,obj.position,'bof');
[mess,res] = ferror(fid);
if res ~= 0
    file = fopen(fid);
    error('HORACE:data_block:io_error',...
        'Error "%s" moving to the start of the record %s.%s in the source file: %s', ...
        mess,obj.base_prop_name,obj.level2_prop_name,file);
end

bindata = fread(fid,obj.size,"*uint8");
[mess,res] = ferror(fid);
if res ~= 0
    file = fopen(fid);
    error('HORACE:data_block:io_error',...
        'Error "%s" writing the data for the record %s.%s in the target file: %s', ...
        mess,obj.base_prop_name,obj.level2_prop_name,file);
end
