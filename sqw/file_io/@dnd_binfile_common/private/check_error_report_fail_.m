function check_error_report_fail_(obj,pos_mess)
% check if error occured during io operation and throw if it does happened
[mess,res] = ferror(obj.file_id_);
if res ~= 0
    error('DND_BINFILE_COMMON:io_error',...
        ['put_sqw: ',pos_mess,' reason: ',mess]);
end
