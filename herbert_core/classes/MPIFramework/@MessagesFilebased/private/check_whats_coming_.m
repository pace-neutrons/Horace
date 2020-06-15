function    [receive_now,n_steps] = check_whats_coming_(obj,task_ids,mess_name,mess_array,n_steps)
% check what messages will be arriving during next step waiting in
% synchroneous mode
%
% Inputs:
% task_ids -- all lab-nums to receive messages from.
% mess_name-- the name of the message to check for.
% mess_array    -- cellarray of size(task_ids) where already received
%                  messages are stored and not-received messages are
%                  represented by empty cells
% mess_received -- boolean array of size task_ids, indicating if some messages
%                  from the labs requested  have already arrived and
%                  receieved
% Returns:
% receive_now    -- boolean array of size task_ids, where true indicates
%                   that message from correspondent task id is present and
%                   can be read.
%

% have it appeared?
[message_names,tid_from] = obj.probe_all(task_ids,mess_name);

mess_to_keep = cellfun(@to_keep,mess_array,'UniformOutput',true);
% verify data messages already present not to force overwriting
% existing received data messages
receive_now = ismember(task_ids,tid_from);
receive_now = receive_now & ~mess_to_keep;

inrerrupt_names = MESS_NAMES.instance().interrupts;
are_interrupts = ismember(message_names,inrerrupt_names);
if any(are_interrupts )
    interrupts_from = tid_from(are_interrupts);
    read_these = ismember(task_ids,interrupts_from );
    receive_now = receive_now | read_these;
end


if obj.DEBUG_
    n_steps  = n_steps +1;
    disp([' Messages arrived at step ',num2str(n_steps), 'vs old mess received']);
    disp(receive_now);
    for i=1:numel(message_names)
        disp(message_names{i});
    end
end

function yes = to_keep(mess)
if isempty(mess)
    yes = false;
    return
end
yes = mess.is_blocking;
