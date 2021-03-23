function [is,err_code,err_message] = check_job_canceled_(obj)
% check if the filebased job is canceled or message "canceled" has been
% send from the task with tid requested.
mess_folder = obj.mess_exchange_folder;
if is_folder(mess_folder)
    is = false;
    err_code = MESS_CODES.ok;
    err_message = '';
else
    err_code    = MESS_CODES.job_canceled;
    err_message = sprintf('Job: "%s" have been canceled. No message folder exist',obj.job_id);
    is          = true;
end
