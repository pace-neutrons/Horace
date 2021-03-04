function [err_code,err_mess,message] = receive_message_(obj,from_task_id,mess_name,is_blocking)
% Receive message from job with the task_id (MPI rank) specified as input
%
% if task_id is empty, or equal to 'any' throws
%
%
%
[is,~,err_mess] = check_job_canceled_(obj); % only framework dead
%  returns canceled, canceled message still can and should be received later.
if is; error('MESSAGE_FRAMEWORK:canceled',err_mess);
end
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
    % may return failed or canceled message
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
            error('MESSAGES_FRAMEWORK:runtime_error',...
                'Timeout waiting for message "%s" for task with id: %d',...
                mess_name,obj.labIndex);
            
        else
            pause(obj.time_to_react_);
            [is,~,err_mess] = check_job_canceled_(obj); % only framework dead
            %  returns canceled, canceled message still can and should be received later.
            if is; error('MESSAGE_FRAMEWORK:canceled',err_mess);
            end
        end
    end
end


% take only the first message directed to this lab, includin cancellation
% message.
mess_fname = obj.job_stat_fname_(obj.labIndex,mess_name_present{1},from_task_id,false);
%
% safeguard against message start being written up
% but have not finished yet when other worker asks for it
n_attempts = 0;
try_limit = 100;
received = false;
[rlock_file,wlock_file] = build_lock_fname_(mess_fname);
%
while is_file(wlock_file) % wait until message is writing.
    % CAN IT LOCK the wlock_file deletion by the sender? There were
    % suspicions.
    %
    % Should not be necessary as probe_all messages above should not pick up
    % locked files, but in reality write_lock may appear on system after
    % the data file, so this check may be useful together with proper
    % renaming of the data file.
    pause(obj.time_to_react_);
    n_attempts = n_attempts +1;
    if n_attempts > try_limit
        warning('write lock %s ignored',wlock_file);
        break; %
    end
end

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
if message.is_blocking
    obj.receive_data_messages_count_(from_task_id+1)=obj.receive_data_messages_count_(from_task_id+1)+1;
end

unlock_(mess_fname); % fancy command to delete file
unlock_(rlock_file);
%pause(0.1);

