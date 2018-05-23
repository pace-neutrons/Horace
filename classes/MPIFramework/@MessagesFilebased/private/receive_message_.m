function [err_code,err_mess,message] = receive_message_(obj,from_task_id,mess_name)
%   Receive message from job with the task_id (MPI rank) specified
% if task_id is empty, receive message from any task.
if ~exist('from_task_id','var') %receive message from any task
    from_task_id = [];
end
if ~isnumeric(from_task_id)
    error('MESSAGES_FRAMEWORK:invalid_argument',...
        'Task_id to recive message should be a number');
end
if ~exist('mess_name','var') %receive any message for this task
    mess_name = '';
end
if ~ischar(mess_name)
    error('MESSAGES_FRAMEWORK:invalid_argument',...
        'mess_name in recive_message command should be a message name (e.g. "starting")');
end

%
message=[];
[is,err_code,err_mess] = check_job_canceled(obj);
if is ; return; end
%
mess_folder = obj.mess_exchange_folder;
mess_present= false;
t0 = tic;
while ~mess_present
    
    folder_contents = dir(mess_folder);
    [mess_names,mid_from,mid_to] = parce_folder_contents_(folder_contents);
    if isempty(mess_names)
        for_this_lab  = false;
    else
        for_this_lab = obj.labIndex == mid_to;
    end
    if any(for_this_lab) % no message intender for this lab received.
        mess_names = mess_names(for_this_lab);
        mid_from   = mid_from(for_this_lab);
        % check if message is from the lab requested
        if ~isempty(from_task_id)
            from_lab_requested = mid_from == from_task_id;
        else
            from_lab_requested = true(size(mid_from));
        end
        mess_names  = mess_names(from_lab_requested );
        mid_from   = mid_from(from_lab_requested );
        % check if message is as requested
        if ~isempty(mess_name)
            tid_requested = ismember(mess_names,{mess_name,'failed'});
            mess_names  = mess_names(tid_requested);
            mid_from    = mid_from (tid_requested);
        end
        if ~isempty(mid_from)
            mess_present = true;
        end
    end
    if ~mess_present % no message intender for this lab is present in system.
        % do waiting for it
        t_passed = toc(t0);
        if t_passed > obj.time_to_fail_
            err_code =  MESS_CODES.timeout_exceeded;
            err_mess = sprintf('Timeout waiting for message "%s" for task with id: %d',...
                mess_name,obj.labIndex);
            return;
        else
            pause(obj.time_to_react_);
            [is,err_code,err_mess] = check_job_canceled(obj);
            if is ; return; end
            continue;
        end
    end
end

% take only the first message directed to this lab
mess_fname = obj.job_stat_fname_(obj.labIndex,mess_names{1},mid_from(1));

%
% safeguard against message start being written up
% but have not finished yet when dispatcher asks for it
ic = 0;
try_limit = 2;
received = false;
while ~received
    try
        mesl = load(mess_fname);
        received = true;
    catch err
        ic = ic+1;
        if ic>try_limit
            err_code  =MESS_CODES.runtime_error;
            err_mess = ...
                sprintf('Can not retrieve message "%s" for task with id: %d does not exist, reason: %s',...
                mess_name,from_task_id,err.message);
            message = [];
            return;
        end
        pause(obj.time_to_react_)
    end
end
% process received message
message = mesl.message;
err_code  =MESS_CODES.ok;
err_mess=[];
delete(mess_fname);


function [is,err_code,err_message] = check_job_canceled(obj)

mess_folder = obj.mess_exchange_folder;
if ~exist(mess_folder,'dir')
    err_code    = MESS_CODES.job_canceled;
    err_message = sprintf('Job with id %s have been canceled',obj.job_id);
    is          = true;
else
    err_code     = [];
    err_message  = '';
    is           = false;
end
