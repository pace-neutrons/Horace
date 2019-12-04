function check_error_report_fail_(obj,pos_mess)
% check if error occured during io operation and throw if it does happened
[mess,res] = ferror(obj.file_id_);
if res ~= 0
    error('SQW_FILE_IO:io_error',...
        '%s -- Reason: %s',pos_mess,mess);
end
