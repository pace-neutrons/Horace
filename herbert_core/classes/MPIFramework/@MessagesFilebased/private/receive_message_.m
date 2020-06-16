function [err_code,err_mess,message] = receive_message_(obj,from_task_id,varargin)
% Receive message from job with the task_id (MPI rank) specified as input
%
% if task_id is empty, or equal to 'any' throws
%
%
message=[];
%
% call parent function to check and validate inputs
[from_task_id,mess_name,is_blocking]=obj.check_receive_inputs(from_task_id,varargin{:});
%

[is,err_code,err_mess] = check_job_canceled_(obj); % only framework dead 
%                        returns canceled, canceled message still can be
%                        received.
if is ; return; end
%
message = obj.get_interrupt(from_task_id);
if ~isempty(message)
    err_code  =MESS_CODES.ok;
    err_mess=[];
    return;
end


mess_present= false;
t0 = tic;
while ~mess_present    
    mess_name_present = obj.probe_all(from_task_id,mess_name);
    if ~isempty(mess_name_present )
        mess_present = true;
    end
    if ~mess_present % no message intended for this lab is present in system.
        if is_blocking
            if obj.is_tested
                error('MESSAGES_FRAMEWORK:runtime_error',...
                    'Can not request blocking message in test mode')
            end
        else
            err_code = MESS_CODES.ok;
            err_mess = [];
            message  = [];
            return;
        end
        
        % do waiting for it
        t_passed = toc(t0);
        if t_passed > obj.time_to_fail_
            error('MESSAGES_FRAMEWORK:invalid_argument',...
                'Timeout waiting for message "%s" for task with id: %d',...
                mess_name,obj.labIndex);
            
        else
            pause(obj.time_to_react_);
            [is,err_code,err_mess] = check_job_canceled_(obj);
            if is ; return; end
            continue;
        end
    end
end


% take only the first message directed to this lab
mess_fname = obj.job_stat_fname_(obj.labIndex,mess_name_present{1},from_task_id);
%
% safeguard against message start being written up
% but have not finished yet when other worker asks for it
n_attempts = 0;
try_limit = 100;
received = false;
[rlock_file,~] = build_lock_fname_(mess_fname);

%deadlock_tries = 100;
lock_(rlock_file);
while ~received    
    try
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
% process received message
message = mesl.message;
err_code  =MESS_CODES.ok;
err_mess=[];

obj.set_interrupt(message,from_task_id);

% check if a message is from the data queue and we need to progress the data
% queue
from_data_queue = message.is_blocking;
progress_queue = false;
if from_data_queue
    first_queue_num = list_queue_messages_(obj.mess_exchange_folder,obj.job_id,...
        message.mess_name,from_task_id,obj.labIndex);
    if first_queue_num(1) >0
        progress_queue = true;
    end
end

if progress_queue % prepare the next message to read -- the oldest message
    % written earlier
    
    [fp,fn] = fileparts(mess_fname);
    next_mess_fname = fullfile(fp,[fn,'.',num2str(first_queue_num(1))]);
    
    [rlock_fileQ,wlock_fileQ] = build_lock_fname_(next_mess_fname);
    success = false;
    n_attempts = 0;
    while ~success
        % next queue file may be in process of writing to.
        if exist(wlock_fileQ,'file') == 2
            pause(obj.time_to_react_)
            continue;
        end
        lock_(rlock_fileQ);
        %
        [success,mess,mess_id]=movefile(next_mess_fname,mess_fname,'f');
        if ~success
            pause(obj.time_to_react_);
            n_attempts = n_attempts+1;
            if n_attempts > try_limit
                error(mess_id,mess);
            end
            %clear target_unlocker;
        end
        unlock_(rlock_fileQ);
    end
    unlock_(rlock_file);
else
    unlock_(mess_fname); % fancy command to delete file
    unlock_(rlock_file);
    %pause(0.1);
end
