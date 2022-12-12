function check_io_error_(obj,fid,read_or_write,add_info)
% check if write operation have completed sucsesfully.
% Throw HORACE:data_block:io_error if it has not

[mess,res] = ferror(fid);
if res ~= 0
    file = fopen(fid);
    error('HORACE:data_block:io_error',...
        'Error "%s" %s data %s for the record %s.%s in the target file: %s', ...
        mess,read_or_write,add_info,obj.base_prop_name,obj.level2_prop_name,file);
end
