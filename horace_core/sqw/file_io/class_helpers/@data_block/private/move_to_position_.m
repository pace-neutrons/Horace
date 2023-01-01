function move_to_position_(obj,fid,pos)
% Do seek operation and check if it was successfull.
% Throw error 'HORACE:data_block:io_error' clarifying the place and reason
% for the error if it has not been succesful.

if isempty(pos)
    pos = obj.position;
end
try
    horace_binfile_interface.move_to_position(fid,pos);
catch ME
    if strcmp(ME.identifier,'HORACE:data_block:io_error')
        error('HORACE:data_block:io_error',...
            '%s moving to the start of the record %s.%s',...
            ME.message,obj.sqw_prop_name,obj.level2_prop_name);
    else
        rethrow(ME);
    end
end
