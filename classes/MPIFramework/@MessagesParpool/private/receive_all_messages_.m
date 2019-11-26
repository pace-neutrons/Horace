function   [all_messages,tid_received_from] = receive_all_messages_(obj,task_ids,mess_name)
% retrieve all messages intended for jobs with task id-s  provided as input
% if message name is also present, return only messages with the name
% specified and wait until the messages with this name arrive from all labs
% requested
%
all_messages = {};
tid_received_from = [];
n_labs = obj.numLabs;
if n_labs == 1 % nothing to do -- lab can not send message to itself (shame)
    return;
end
%
if ~exist('task_ids','var')
    task_ids = [];
end
if isempty(task_ids) || (ischar(task_ids) && strcmpi(task_ids,'all'))
    task_ids = 1:n_labs;
end

lock_until_received = true;
if ~exist('mess_name','var')
    mess_name = '';
end
if isempty(mess_name) || strcmp(mess_name,'all')
    lock_until_received = false;
end

not_this_id = task_ids ~= obj.labIndex;
tid_requested = task_ids(not_this_id);
tid_received_from = tid_requested;

mc = mess_cache.instance();
%log_file_h = mc.log_file_h;

[all_messages,mess_present] = mc.get_cache_messages(tid_requested,mess_name,lock_until_received);
n_requested = numel(all_messages);
% if any(mess_present)
%     fprintf(log_file_h,' Old messages present\n');
% end

% check new messages received from other labs
[mess_names,tid_from] = labProbe_messages_(obj,tid_requested);
present_now = ismember(tid_requested,tid_from);

all_received = false;
n_calls = 0;

t0 = tic;
is_failed = false;
while ~all_received
    n_cur_mess = 0;
    for i=1:n_requested % receive all existing messages in the messages queue
        if ~present_now(i); continue;
        end
        n_cur_mess = n_cur_mess+1;
        tid_to_ask = tid_from(n_cur_mess);
        %fprintf(log_file_h,'New message %s N %d fron TID %d present\n',...
        %    mess_names{n_cur_mess},i,tid_to_ask);
        
        [ok,err_exception,message]=receive_message_(obj,tid_to_ask,mess_names{n_cur_mess});
        if ok ~= MESS_CODES.ok
            if ok == MESS_CODES.job_canceled
                is_failed = true;
                message = aMessage('canceled');
                message.payload = err_exception;
            else
                rethrow(err_exception);
            end
        end
        %fprintf(log_file_h,'Received new message %s N %d from TID %d present\n',...
        %    message.mess_name,i,tid_to_ask);
        if strcmp(message.mess_name,'failed') || is_failed
            % failed message is persistent.
            % Make it ready for the next possible receive request
            mc.push_messages(tid_to_ask,message);
            is_failed = true;
        else
            is_failed = false;
        end
        % handle received message and either store it for the future or
        % place in outputs
        if lock_until_received
            if is_failed || strcmp(mess_names{n_cur_mess},mess_name)
                %store resulting message
                % Data messages should be retained until received, anything
                % else would be overwritten
                if isempty(all_messages{i})
                    all_messages{i}  = message;
                else
                    if MESS_NAMES.is_queuing(all_messages{i}.mess_name)
                        mc.push_messages(tid_to_ask,message);
                    else
                        all_messages{i}  = message;
                    end
                end
                mess_present(i)  = true;
            else
                % wrong message, receive and store it for the future
                mc.push_messages(tid_to_ask,message);
            end
        else
            all_messages{i}  = message;
            mess_present(i)  = true;
        end
    end
%     fprintf(log_file_h,'mess present: ');
%     for j=1:numel(mess_present)
%         fprintf(log_file_h,' %d ',mess_present(j));
%     end
%     fprintf(log_file_h,'\n');
%     
    % check if we want to wait for more messages to arrive
    if lock_until_received
        if all(mess_present)
            all_received = true;
            %fprintf(log_file_h,'all received\n');
        else
            t1 = toc(t0);
            if t1>obj.time_to_fail_
                error('PARPOOL_MESSAGES:runtime_error',...
                    'Timeout waiting for receiving all messages')
            end
            
            [mess_names,tid_from] = labProbe_messages_(obj,tid_requested);
%             if numel(tid_from) > 0
%                 fprintf(log_file_h,'more exist\n');
%                 for j=1:numel(tid_from)
%                     fprintf(log_file_h,'Mess %s from %d\n',mess_names{j},tid_from(j));
%                 end
%             end
            present_now = ismember(tid_requested,tid_from);
            n_calls = n_calls +1;
        end
        pause(0.1);
        
        
    else % if not need to wait, complete loop of receiving messages
        all_received = true;
    end
end

if ~lock_until_received
    all_messages = all_messages(mess_present);
    tid_received_from = tid_received_from(mess_present);
end

