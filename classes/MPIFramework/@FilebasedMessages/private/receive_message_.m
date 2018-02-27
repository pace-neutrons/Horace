function [err_code,err_mess,message] = receive_message_(obj,task_id,mess_name)
%   Receive message for job with the task_id (MPI rank) specified)
if ~exist('task_id','var')
    error('MESSAGES_FRAMEWORK:invalid_argument',...
        'Task_id to recive message should be present');
end
if ~isnumeric(task_id)
    error('MESSAGES_FRAMEWORK:invalid_argument',...
        'Task_id to recive message should be a number');
end
blocking_message = false;
if ~exist('mess_name','var')
    blocking_message = true;
    mess_name = '';
end
if ~ischar(mess_name)
    error('MESSAGES_FRAMEWORK:invalid_argument',...
        'mess_name in recive_message command should be a message name (e.g. "starting")');
end
%
message=[];
if ~exist(obj.mess_exchange_folder_,'dir')
    err_code = MES_CODES.job_canceled;
    err_mess = sprintf('Job with id %s have been canceled',obj.job_id);
    return;
end
%
if blocking_message % not yet implemented, just receive all messages for this task id
    mess_folder = obj.mess_exchange_folder_;
    folder_contents = dir(mess_folder);
    if numel(folder_contents )==0
        return;
    end
    [mess_names,task_ids] = parce_folder_contents_(folder_contents);
    intended = (task_ids == task_id);
    if any(intended)
    else
    end
    
else
    pause(obj.time_to_react_);
    mess_fname = obj.job_stat_fname_(task_id,mess_name);
    if exist(mess_fname,'file') ~= 2
        err_code = MES_CODES.not_exist;
        err_mess = sprintf('Message "%s" for task with id: %d does not exist',mess_name,task_id);
        message = [];
        return;
    end
end
%
% safeguard against message start beeing written up
% but have not finished yet when dispatcher asks for it
ic = 1;
try_limit = 4;
received = false;
while ~received
    try
        mesl = load(mess_fname);
        received = true;
    catch err
        ic = ic+1;
        if ic>try_limit
            err_code  =MES_CODES.runtime_error;
            err_mess = ...
                sprintf('Can not retrieve message "%s" for task with id: %d does not exist, reason: s%',...
                mess_name,task_id,err.message);
            message = [];
            return;
        end
        pause(1)
    end
end
% process received message
message = mesl.message;
err_code  =MES_CODES.ok;
err_mess=[];
delete(mess_fname);




