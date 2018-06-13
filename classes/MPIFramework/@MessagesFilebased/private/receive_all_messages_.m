function   [all_messages,tid_received_from] = receive_all_messages_(obj,tid_requested,mess_name)
% retrieve all messages sent from jobs with id provided. if ids are empty,
% all messages, intended for this job.
%
if ~exist('tid_requested','var') || (ischar(tid_requested) && strcmpi(tid_requested,'all'))
    tid_requested = 1:obj.numLabs;
end
this_tid = tid_requested == obj.labIndex;
if any(this_tid)
    tid_requested = tid_requested(~this_tid);
end

synchronize = true;
if ~exist('mess_name','var')
    mess_name = '';
    synchronize = false;
end
n_requested = numel(tid_requested);
all_messages = cell(n_requested ,1);
mess_received = false(n_requested ,1);
tid_received_from = zeros(n_requested ,1);

[message_names,tid_from] = list_all_messages_(obj,tid_requested,mess_name);
[tid_from,im] = unique(tid_from);
message_names = message_names(im);
tid_exist = ismember(tid_requested,tid_from);

all_received = false;
t0 = tic;
while ~all_received
    for i=1:numel(tid_exist)
        if ~tid_exist(i); continue; end
        
        [ok,err_mess,message]=receive_message_(obj,tid_requested(i),mess_name);
        if ok ~= MESS_CODES.ok
            if ok == MESS_CODES.job_cancelled
                error('MESSAGE_FRAMEWORK:cancelled',err_mess);
            else
                error('FILEBASED_MESSAGES:runtime_error',...
                    'Can not receive existing message: %s, Err: %s',...
                    message_names{i},err_mess);
            end
        end
        all_messages{i} = message;
        tid_received_from(i) = tid_requested(i);
        mess_received(i) = true;
    end
    
    if synchronize
        all_received = all(mess_received);
        if ~all_received
            t1 = toc(t0);
            if t1>obj.time_to_fail_
                error('FILEBASED_MESSAGES:runtime_error',...
                    'Timeout waiting for receiving all messages')
            end
            [message_names,tid_from] = list_all_messages_(obj,tid_requested,mess_name);
            [tid_from,im] = unique(tid_from);
            message_names = message_names(im);
            tid_exist = ismember(tid_requested,tid_from);
            
            pause(0.1);
        end
    else
        all_received = true;
    end
    
end
if ~synchronize
    all_messages = all_messages(mess_received);
    tid_received_from = tid_received_from(mess_received);
end
% sort received messages according to task id to ensure consistent sequence
% of task messages
if ~isempty(tid_received_from)
    [tid_received_from,ic]  = sort(tid_received_from);
    all_messages  = all_messages(ic);
end
