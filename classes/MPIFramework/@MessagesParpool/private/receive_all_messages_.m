function   [all_messages,tid_received_from,obj] = receive_all_messages_(obj,task_ids,mess_name)
% retrieve all messages intended for jobs with task id-s  provided as input
% if message name is also present, return only messages with the name
% specified and wait until the messages with this name arrive from all labs
% requested
%
n_labs = obj.numLabs;
if n_labs == 1 % nothing to do -- lab can not send message to itself (shame)
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

synchronize = true;
if ~exist('mess_name','var')
    mess_name = '';
end
if isempty(mess_name) || strcmp(mess_name,'all')
    synchronize = false;
end

not_this_id = task_ids ~= obj.labIndex;
tid_requested = task_ids(not_this_id);
% prepare outputs
n_requested = numel(tid_requested);
all_messages = cell(n_requested ,1);
cash_messages = cell(n_requested ,1);
tid_received_from = tid_requested;

% retrieve all messages received earlier and copy them into output array
if synchronize
    [old_mess,old_tids]= mess_cash.instance().pop_messages(tid_requested,mess_name);
else
    [old_mess,old_tids]= mess_cash.instance().pop_messages(tid_requested);
end
mess_present = ismember(tid_requested,old_tids);
if any(mess_present)
    n_message = 0;
    for i=1:n_requested
        if mess_present(i)
            n_message = n_message+1;
            all_messages{i} = old_mess{n_message};
        end
    end
end

% check new messages received from other labs
[mess_names,tid_from] = labProbe_messages_(obj,tid_requested);
present_now = ismember(tid_requested,tid_from);

all_received = false;
n_calls = 0;
t0 = tic;
while ~all_received
    n_cur_mess = 0;
    for i=1:n_requested
        if ~present_now(i)
            continue;
        end
        n_cur_mess = n_cur_mess+1;
        tid_to_ask = tid_from(n_cur_mess);
        %fprintf(' receiving message %s from task: %d\n',mess_names{n_cur_mess},tid_to_ask)
        [ok,err_exception,message]=receive_message_(obj,tid_to_ask,mess_names{n_cur_mess});
        if ~ok
            rethrow(err_exception);
        end
        % handle received message and either store it for the future or
        % place in outputs
        if synchronize
            if strcmp(mess_names{n_cur_mess},mess_name) || strcmp(message.mess_name,'failed')
                %store resulting message
                all_messages{i}  = message;
                mess_present(i)  = true;
            else
                % wrong message, receive and store it for the future
                cash_messages{tid_to_ask}= message;
            end
        else
            all_messages{i}  = message;
            mess_present(i)  = true;
        end
        
    end
    % check if we want to wait for more messages to arrive
    if synchronize
        if all(mess_present)
            all_received = true;
        else
            t1 = toc(t0);
            if t1>obj.time_to_fail_
                error('PARPOOL_MESSAGES:runtime_error',...
                    'Timeout waiting for receiving all messages')
            end
            
            [mess_names,tid_from] = labProbe_messages_(obj,tid_requested);
            present_now = ismember(tid_requested,tid_from);
            n_calls = n_calls +1;
        end
    else % if not need to wait, complete loop of receiving messages
        all_received = true;
    end
end

cash_mess_left = cellfun(@(x)~isempty(x),cash_messages,'UniformOutput',true);
if any(cash_mess_left)
    mc = mess_cash.instance();
    mc.push_messages(cash_mess_left,cash_messages);
end

if ~synchronize
    all_messages = all_messages(mess_present);
    tid_received_from = tid_received_from(mess_present);
end

