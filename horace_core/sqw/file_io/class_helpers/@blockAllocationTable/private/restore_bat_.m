function obj = restore_bat_(obj,fid,pos)
% read block allocation table at specified location in the
% binary file and restore it into memory

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

%
bat_size = fread(fid,1,'uint32');
%
bindata = fread(fid,bat_size,'*uint8');
%
try
    horace_binfile_interface.check_read_error(fid);
catch ME
    if strcmp(ME.identifier,'HORACE:data_block:io_error')
        error('HORACE:data_block:io_error',...
            '%s the BlockAllocationTable data',...
            ME.message);
    else
        rethrow(ME);
    end
end
obj.ba_table = bindata;