function check_write_error_(obj,fid,add_info)
% check if write operation have completed sucsesfully.
% Throw HORACE:data_block:io_error if it has not

try
    horace_binfile_interface.check_write_error(fid);
catch ME
    if strcmp(ME.identifier,'HORACE:data_block:io_error')
        error('HORACE:data_block:io_error',...
            '%s %s data %s for the record %s.%s',...
            ME.message,add_info,obj.base_prop_name,obj.level2_prop_name);
    else
        rethrow(ME);
    end
end
