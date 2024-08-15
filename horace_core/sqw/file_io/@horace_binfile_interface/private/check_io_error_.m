function check_io_error_(fid,read_or_write,addinfo)
% check if write operation have completed successfully.
% Throw HORACE:data_block:io_error if it has not

[mess,res] = ferror(fid);
if res ~= 0
    [file,acc] = fopen(fid);
    if isempty(addinfo)
        error('HORACE:data_block:io_error',...
            'file: "%s", IO mode: "%s". %s error: "%s"', ...
            file,acc,read_or_write,mess);
    else
        error('HORACE:data_block:io_error',...
            'file: "%s", %s %s. %s Error: "%s"', ...
            file,acc,read_or_write,addinfo,mess);

    end
end
