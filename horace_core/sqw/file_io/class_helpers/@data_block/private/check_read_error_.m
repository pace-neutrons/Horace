function check_read_error_(obj,fid,add_info)
% check if read operation have completed successfully.
% Throw HORACE:data_block:io_error if it has not

try
    horace_binfile_interface.check_read_error(fid);
catch ME
    if strcmp(ME.identifier,'HORACE:data_block:io_error')
        error('HORACE:data_block:io_error',...
            '%s %s data %s for the record %s.%s',...
            ME.message,add_info,obj.sqw_prop_name,obj.level2_prop_name);
    else
        rethrow(ME);
    end
end
