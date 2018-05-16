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

if ~exist('mess_name','var')
    mess_name = '';
end
all_messages = cell(numel(tid_requested),1);
tid_received_from = zeros(numel(tid_requested),1);
all_received = false;
[message_names,tid_from] = list_all_messages_(obj,tid_requested,mess_name);
tid_exist = ismember(tid_requested,tid_from);
n_requested = numel(tid_requested);
n_received = 0;
t0 = tic;
while ~all_received
    for i=1:numel(tid_exist)
        if ~tid_exist(i); continue; end
        
        [ok,err_mess,message]=receive_message_(obj,tid_requested(i),mess_name);
        if ~ok
            error('FILEBASED_MESSAGES:runtime_error',...
                'Can not receive existing message: %s, Err: %s',...
                message_names{i},err_mess);
        end
        all_messages{i} = message;
        tid_received_from(i) = tid_requested(i);
    end
    n_received  = n_received +numel(tid_from);
    if n_received >= n_requested
        all_received = true;
    else
        t1 = toc(t0);
        if t1>obj.time_to_fail_
            error('FILEBASED_MESSAGES:runtime_error',...
                'Timeout waiting for receiving all messages')
        end
        [message_names,tid_from] = list_all_messages_(obj,tid_requested,mess_name);
        tid_exist = ismember(tid_requested,tid_from);
    end
    
end
