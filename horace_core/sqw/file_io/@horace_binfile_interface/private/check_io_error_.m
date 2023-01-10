function check_io_error_(fid,read_or_write)
% check if write operation have completed sucsesfully.
% Throw HORACE:data_block:io_error if it has not

[mess,res] = ferror(fid);
if res ~= 0
    file = fopen(fid);
    error('HORACE:data_block:io_error',...
        'file: "%s". %s Error "%s"', ...
        file,read_or_write,mess);   
end
