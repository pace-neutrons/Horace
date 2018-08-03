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
[is,err_code,err_mess] = check_job_cancelled(obj);
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
            mid_from    = mid_from (tid_requested);
            mess_names  = mess_names(tid_requested);
        end
        if ~isempty(mid_from)
            mess_present = true;
        end
    end
    if ~mess_present % no message intended for this lab is present in system.
        % do waiting for it
        t_passed = toc(t0);
        if t_passed > obj.time_to_fail_
            err_code =  MESS_CODES.timeout_exceeded;
            err_mess = sprintf('Timeout waiting for message "%s" for task with id: %d',...
                mess_name,obj.labIndex);
            return;
        else
            pause(obj.time_to_react_);
            [is,err_code,err_mess] = check_job_cancelled(obj);
            if is ; return; end
            continue;
        end
    end
end


% take only the first message directed to this lab
mess_fname = obj.job_stat_fname_(obj.labIndex,mess_names{1},mid_from(1));
if strcmp(mess_names{1},'failed')
    is_failed = true;
else
    is_failed = false;
end
%
% safeguard against message start being written up
% but have not finished yet when dispatcher asks for it
n_attempts = 0;
try_limit = 10;
received = false;
while ~received
    
    lock_file = build_lock_fname_(mess_fname);
    if exist(lock_file,'file') == 2
        pause(obj.time_to_react_)
        continue;
    end
    try
        fh = fopen(lock_file,'wb');
        file_unlocker = onCleanup(@()unlock_(fh,lock_file));
        mesl = load(mess_fname);
        received = true;
    catch err
        n_attempts = n_attempts+1;
        if n_attempts>try_limit
            rethrow(err);
        end
        pause(obj.time_to_react_)
    end
end
% check if a message is from the data queue and we need to progress the data
% queue
from_data_queue = MESS_NAMES.is_queuing(mess_names{1});
progress_queue = false;
if from_data_queue
    first_queue_num = list_these_messages_(obj.mess_exchange_folder,obj.job_id,...
        mess_names{1},from_task_id,obj.labIndex);
    if first_queue_num(1) >0
        progress_queue = true;
    end
end
% process received message
message = mesl.message;
err_code  =MESS_CODES.ok;
err_mess=[];

if is_failed  % make failed message persistent
    return;
end

if progress_queue % prepare the next message to read -- the oldest message
    % written earlier
    
    [fp,fn] = fileparts(mess_fname);
    next_mess_fname = fullfile(fp,[fn,'.',num2str(first_queue_num(1))]);
    
    lock_file = build_lock_fname_(next_mess_fname);
    success = false;
    n_attempts = 0;
    while ~success
        if exist(lock_file,'file') == 2
            pause(obj.time_to_react_)
            continue;
        end
        
        [success,mess,mess_id]=movefile(next_mess_fname,mess_fname,'f');
        if ~success
            pause(obj.time_to_react_);
            n_attempts = n_attempts+1;
            if n_attempts > try_limit
                error(mess_id,mess);
            end
        end
    end
else
    delete(mess_fname);
    pause(0.1);
end
clear file_unlocker




function [is,err_code,err_message] = check_job_cancelled(obj)

mess_folder = obj.mess_exchange_folder;
if ~exist(mess_folder,'dir')
    err_code    = MESS_CODES.job_cancelled;
    err_message = sprintf('Job with id %s have been cancelled',obj.job_id);
    is          = true;
else
    err_code     = [];
    err_message  = '';
    is           = false;
end
