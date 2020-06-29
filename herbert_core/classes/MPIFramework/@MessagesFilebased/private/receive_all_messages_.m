function   [all_messages,tid_received_from] = receive_all_messages_(obj,task_ids,mess_name,varargin)
% retrieve all messages sent from jobs with id provided. if ids are empty,
% all messages, intended for this job.
%
if ~exist('task_ids','var') || isempty(task_ids) || (ischar(task_ids) && strcmpi(task_ids,'all'))
    task_ids = 1:obj.numLabs;
end
not_this = task_ids ~= obj.labIndex;
if ~all(not_this)
    task_ids = task_ids(not_this);
end


if ~exist('mess_name','var') || isempty(mess_name)
    mess_name = 'any';
end
lock_until_received = obj.check_is_blocking(mess_name,varargin);
if lock_until_received
    how = '-synchronously';
else
    how = '-asynchronously';
end

if obj.DEBUG_
    disp(['********** ',how,'  waiting for message: ',mess_name,' to arrive from tasks: ']);
    disp(task_ids')
end


n_requested = numel(task_ids);
all_messages = cell(1,n_requested);
mess_received = false(1,n_requested);
tid_received_from = zeros(1,n_requested);
%mess_name = arrayfun(@(x)(mess_name),mess_received,'UniformOutput',false);

[message_names,tid_from] = obj.probe_all(task_ids,mess_name);
%
present_now = ismember(task_ids,tid_from);
if obj.DEBUG_
    disp(' Messages present initially:');
    disp(present_now');
end
mess_names_present = all_messages;
mess_names_present(present_now) = message_names(:);
%
%
all_received = false;
n_steps = 0;
t0 = tic;
while ~all_received
    for i=1:n_requested
        if present_now(i)
            [ok,err_mess,message]=obj.receive_message(task_ids(i),mess_names_present{i},'-synch');
            if ok ~= MESS_CODES.ok
                if ok == MESS_CODES.job_canceled
                    error('MESSAGE_FRAMEWORK:canceled',err_mess);
                else
                    error('MESSAGE_FRAMEWORK:runtime_error',...
                        'Can not receive existing message: %s, Err: %s',...
                        mess_names_present{i},err_mess);
                end
            end
            all_messages{i} = message;
            tid_received_from(i) = task_ids(i);
            mess_received(i) = true;
        else % check canceled message
            mess=obj.probe_all(task_ids(i),'canceled');
            if ~isempty(mess)
                [ok,err_message,message]=obj.receive_message(task_ids(i),'canceled');
                if ~ok
                    error('MESSAGE_FRAMEWORK:canceled',...
                        'Error receiving canceled message: %s',err_message);
                end
                all_messages{i} = message;
                tid_received_from(i) = task_ids(i);
                mess_received(i) = true;
            end
            
        end
    end
    if obj.DEBUG_
        disp(' Messages received:');
        disp(mess_received);
        for i=1:numel(all_messages)
            disp(all_messages{i});
            if ~isempty(all_messages{i})
                disp(all_messages{i}.payload)
            end
        end
        
    end
    
    if lock_until_received
        all_received = all(mess_received);
        if ~all_received
            t1 = toc(t0);
            if t1>obj.time_to_fail_; error('MESSAGES_FRAMEWORK:runtime_error',...
                    'Timeout waiting for receiving all messages')
            end
            
            [present_now,mess_names_present,n_steps] = ...
                obj.check_whats_coming(task_ids,mess_name,...
                all_messages,n_steps);
            
            if obj.is_tested && ~any(present_now)
                error('MESSAGES_FRAMEWORK:runtime_error',...
                    'Issued request for missing blocking message in test mode');
            end
            pause(0.1);
        end
    else
        break;
    end
    
end

all_messages = all_messages(mess_received);
tid_received_from = tid_received_from(mess_received);

% sort received messages according to task id to ensure consistent sequence
% of task messages
if ~isempty(tid_received_from)
    [tid_received_from,ic]  = sort(tid_received_from);
    all_messages  = all_messages(ic);
end

