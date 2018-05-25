function   [all_messages,tid_received_from,obj] = receive_all_messages_(obj,task_ids,mess_name)
% retrieve all messages intended for jobs with id provided
%
n_labs = obj.numLabs;
if n_labs == 1
    all_messages = {};
    tid_received_from = [];
    return;
end
%
if ~exist('task_ids','var')
    task_ids = [];
end
if isempty(task_ids) || (ischar(task_ids) && strcmpi(task_ids,'all'))
    task_ids = 1:n_labs;
end

wait_2_receive_all = true;
if ~exist('mess_name','var')
    wait_2_receive_all = false;
end
if isempty(mess_name) || strcmp(mess_name,'all')
    wait_2_receive_all = false;
end

not_this_id = task_ids ~= obj.labIndex;
tid_requested = task_ids(not_this_id);
% prepare outputs
n_requested = numel(tid_requested);
all_messages = cell(n_requested ,1);
tid_received_from = tid_requested;

if ~wait_2_receive_all
    mess_present = false(n_requested,1);
end

%

[mess_names,tid_from] = labProbe_messages_(obj,tid_requested);

received_messages = obj.mess_stack_;
% collect all messages received earlier and copy them into output array
n_received  = 0;
for i=1:n_requested
    the_tid = tid_requested(i);
    if ~isempty(received_messages{the_tid})
        the_prev_mess = received_messages{the_tid};
        if wait_2_receive_all && ~strcmp(the_prev_mess.mess_name,mess_name)
            continue;
        end
        all_messages{i} = the_prev_mess;
        n_received    = n_received  + 1;
        received_messages{the_tid}=[];
        if ~wait_2_receive_all
            mess_present(i) = true;
        end
    end
end

present_now = ismember(tid_requested,tid_from);
all_received = false;

t0 = tic;
while ~all_received
    n_present_mess = 1;
    for i=1:n_requested
        if ~present_now(i)
            continue;
        end
        tid_now = tid_from(n_present_mess);
        [ok,err_exception,message]=receive_message_(obj,tid_now,mess_names{n_present_mess});
        if ~ok
            rethrow(err_exception);
        end
        % handle received message and either store it for the future or
        % place in outputs
        if wait_2_receive_all
            if strcmp(mess_names{n_present_mess},mess_name) || strcmp(message.mess_name,'failed')
                %store resulting message
                all_messages{i}  = message;
                n_received  = n_received +1;
            else
                % wrong message, receive and store it for the future
                received_messages{tid_now}= message;
            end
        else
            all_messages{i}  = message;
            mess_present(i)  = true;
        end
        n_present_mess = n_present_mess+1;
    end
    % check if we want to wait for more messages to arrive
    if wait_2_receive_all
        if n_received >= n_requested
            all_received = true;
        else
            t1 = toc(t0);
            if t1>obj.time_to_fail_
                error('PARPOOL_MESSAGES:runtime_error',...
                    'Timeout waiting for receiving all messages')
            end
            
            [mess_names,tid_from] = labProbe_messages_(obj,tid_requested);
            present_now = ismember(tid_requested,tid_from);
        end
    else % if not need to wait, complete loop of receiving messages
        all_received = true;
    end
    
end
if ~wait_2_receive_all
    all_messages = all_messages(mess_present);
    tid_received_from = tid_received_from(mess_present);
end
obj.mess_stack_ = received_messages;
