function check_error_report_fail_(file_id_,pos_mess)
% check if error occured during io operation and throw if it does happened
[mess,res] = ferror(file_id_);
if res ~= 0
    error('COMBINE_SQW_PIX_JOB:io_error',...
        ['put_sqw: ',pos_mess,' reason: ',mess]);
end
