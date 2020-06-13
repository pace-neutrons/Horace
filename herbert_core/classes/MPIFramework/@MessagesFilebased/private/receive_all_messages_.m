function   [all_messages,tid_received_from] = receive_all_messages_(obj,task_ids,mess_name,varargin)
% retrieve all messages sent from jobs with id provided. if ids are empty,
% all messages, intended for this job.
%
if ~exist('task_ids','var') || isempty(task_ids) || (ischar(task_ids) && strcmpi(task_ids,'all'))
    task_ids = 1:obj.numLabs;
end
this_tid = task_ids == obj.labIndex;
if any(this_tid)
    task_ids = task_ids(~this_tid);
end


if ~exist('mess_name','var') || isempty(mess_name)
    mess_name = 'any';
end
lock_until_received = obj.check_is_blocking(mess_name,varargin);

if obj.DEBUG_
    if lock_until_received
        how = ' synchronously';
    else
        how = ' asynchronously';
    end
    disp(['**********',how,'  waiting for message: ',mess_name,' to arrive from tasks: ']);
    disp(task_ids')
end



n_requested = numel(task_ids);
all_messages = cell(n_requested ,1);
mess_received = false(n_requested ,1);
tid_received_from = zeros(n_requested ,1);
%mess_name = arrayfun(@(x)(mess_name),mess_received,'UniformOutput',false);

[message_names,tid_from] = obj.probe_all(task_ids,mess_name);
%
present_now = ismember(task_ids,tid_from);
if obj.DEBUG_
    disp(' Messages present initially:');
    disp(present_now');
end
% % define list of special states to verify alongside with messages requested
% special_states = MESS_NAMES.instance().state_messages;
% interrupts     = MESS_NAMES.instance().interrupts;
% non_interrupt  = ~ismember(special_states,interrupts);
% special_states = special_states(non_interrupt);


all_received = false;
nsteps = 0;
t0 = tic;
while ~all_received
    for i=1:n_requested
        if present_now(i)
            [ok,err_mess,message]=receive_message_(obj,task_ids(i),mess_name);
            if ok ~= MESS_CODES.ok
                if ok == MESS_CODES.job_canceled
                    error('MESSAGE_FRAMEWORK:canceled',err_mess);
                else
                    error('FILEBASED_MESSAGES:runtime_error',...
                        'Can not receive existing message: %s, Err: %s',...
                        message_names{i},err_mess);
                end
            end
            all_messages{i} = message;
            tid_received_from(i) = task_ids(i);
            mess_received(i) = true;
        else % check canceled message
            [is,err_code,err_message] = check_job_canceled_(obj,task_ids(i));
            if is
                if err_code == MESS_CODES.job_canceled_request
                    [ok,err_message,message]=receive_message_(obj,task_ids(i),'canceled');
                    if ~ok
                        error('MESSAGE_FRAMEWORK:canceled',...
                            'Error receiving canceled message: %s',err_message);
                    end
                    all_messages{i} = message;
                    tid_received_from(i) = task_ids(i);
                    mess_received(i) = true;
                else
                    error('MESSAGE_FRAMEWORK:canceled',err_message);
                end
            end
            
        end
    end
    if obj.DEBUG_
        disp(' Messages received:');
        disp(mess_received');
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
            if t1>obj.time_to_fail_
                error('FILEBASED_MESSAGES:runtime_error',...
                    'Timeout waiting for receiving all messages')
            end
            % have it appeared?
            [message_names,tid_from] = obj.probe_all(task_ids,mess_name);
            %[tid_from,im] = unique(tid_from);
            %message_names = message_names(im);
            present_now = ismember(task_ids,tid_from);
            
            % verify data messages already present not to force overwriting
            % existing received data messages
            present_now = present_now & ~mess_received';
            if obj.DEBUG_
                nsteps  = nsteps +1;
                disp([' Messages arrived at step ',num2str(nsteps), 'vs old mess received']);
                disp(present_now);
                for i=1:numel(message_names)
                    disp(message_names{i});
                end
                disp(mess_received');
            end
            if obj.is_tested
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



