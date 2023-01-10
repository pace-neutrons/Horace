function obj = store_bat_(obj,fid,pos)
% store block allocation table at specified location in the
% binary file.

try
    horace_binfile_interface.move_to_position(fid,pos);
catch ME
    if strcmp(ME.identifier,'HORACE:data_block:io_error')
        error('HORACE:data_block:io_error',...
            '%s moving to the start of the BlockAllocationTable postition',...
            ME.message);
    else
        rethrow(ME);
    end
end

bindata = obj.ba_table;
%
fwrite(fid,uint32(numel(bindata)),'uint32');
%
fwrite(fid,bindata,"uint8");

try
    horace_binfile_interface.check_write_error(fid);
catch ME
    if strcmp(ME.identifier,'HORACE:data_block:io_error')
        error('HORACE:data_block:io_error',...
            '%s the BlockAllocationTable data',...
            ME.message);
    else
        rethrow(ME);
    end
end
