function [all_messages,tid_received_from] = receive_all_messages_(obj,task_ids,mess_name,varargin)
% retrieve all messages sent from jobs with id provided. if ids are empty,
% grab all messages, intended for this job.
%
%
if ~exist('task_ids', 'var') || isempty(task_ids) || (ischar(task_ids) && strcmpi(task_ids,'all'))
    task_ids = 1:obj.numLabs;
end
if ischar(task_ids)
    error('MESSAGES_FRAMEWORK:invalid_argument',...
        ' Function accepts only one form of task_ids input argument: "all" but received unknown request %s',...
        task_ids);
end

not_this = task_ids ~= obj.labIndex;
if ~all(not_this)
    task_ids = task_ids(not_this);
end
if ~exist('mess_name', 'var') || isempty(mess_name)
    mess_name = 'any';
end
% if it is blocking channel we are using or not.
lock_until_received = obj.check_is_blocking(mess_name,varargin);

n_requested = numel(task_ids);
all_messages = cell(1,n_requested);
mess_received = false(1,n_requested);
tid_received_from = zeros(1,n_requested);

[message_names,tid_from] = obj.probe_all(task_ids,mess_name);
%
present_now = ismember(task_ids,tid_from);
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
            [ok,err_mess,message]=obj.receive_message_internal(task_ids(i),mess_names_present{i},lock_until_received);
            if ok ~= MESS_CODES.ok
                error('MESSAGE_FRAMEWORK:runtime_error',...
                    'Can not receive existing message: %s, Err: %s',...
                    mess_names_present{i},err_mess);
            end
            if isempty(message) %message was present, but is getting
                % overwritten when tried to receive it. (filebased
                % framework feature) Making it non-present (it will be 
                % received next attempt)
                mess_received(i) = false;
                mess_names_present{i} = '';
                present_now(i) = false;
            else
                all_messages{i} = message;
                tid_received_from(i) = task_ids(i);
                mess_received(i) = true;
            end
            if obj.throw_on_interrupts
                if message.is_persistent % its interrupt % The question is is it better to throw on interrupt
                    if ~isempty(message.fail_text)
                        error('MESSAGE_FRAMEWORK:canceled',...
                            'Node %d: interrupted receive from node %d by cancellation message: %s, Reason: %s',...
                            obj.labIndex,task_ids(i),message.mess_name,message.fail_text);
                    else
                        error('MESSAGE_FRAMEWORK:canceled',...
                            'Node %d: interrupted receive from node %d by cancellation message %s',...
                            obj.labIndex.task_ids(i),message.mess_name);
                    end
                end
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
            pause(obj.time_to_react_);
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

