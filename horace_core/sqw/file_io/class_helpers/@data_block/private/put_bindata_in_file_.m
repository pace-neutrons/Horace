function  obj = put_bindata_in_file_(obj,fid,bindata)
%PUT_BINDATA_IN_FILE_ store array of bytes into opened binary file
%
% Inputs:
% fid      -- opened file handle
% bindata  -- array of bytes to store on hdd
%
fseek(fid,obj.position,'bof');
[mess,res] = ferror(fid);
if res ~= 0 
    file = fopen(fid);
    error('HORACE:data_block:io_error',...
        'Error "%s" moving to the start of the record %s.%s in the target file: %s', ...
        mess,obj.base_prop_name,obj.level2_prop_name,file);

end

fwrite(fid,bindata,"uint8");
[mess,res] = ferror(fid);
if res ~= 0 
    file = fopen(fid);
    error('HORACE:data_block:io_error',...
        'Error "%s" writing the data for the record %s.%s in the target file: %s', ...
        mess,obj.base_prop_name,obj.level2_prop_name,file);

end
