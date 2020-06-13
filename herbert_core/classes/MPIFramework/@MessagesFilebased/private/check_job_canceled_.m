function [is,err_code,err_message] = check_job_canceled_(obj,tid)
% check if the filebased job is canceled or message "canceled" has been
% send from the task with tid requested.
mess_folder = obj.mess_exchange_folder;
if ~exist(mess_folder,'dir')
    err_code    = MESS_CODES.job_canceled;
    err_message = sprintf('Job: "%s" have been canceled',obj.job_id);
    is          = true;
else
    if exist('tid','var')
        [mess,from_tid]=obj.probe_all(tid,'canceled');
        if isempty(mess)
            err_code     = [];
            err_message  = '';
            is           = false;
        else
            is          = true;
            err_code    = MESS_CODES.job_canceled_request;
            err_message = sprintf('Job: "%s" received canceled message from Task with id: %d',...
                obj.job_id,from_tid);
        end
    else
        err_code     = [];
        err_message  = '';
        is           = false;
    end
end
