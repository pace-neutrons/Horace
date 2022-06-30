function    [receive_now,message_names_array,n_steps] = check_whats_coming_(obj,task_ids,mess_name,mess_array,n_steps)
% check what messages will be arriving during next step waiting in
% synchroneous mode
%
% Inputs:
% task_ids - all lab-nums to receive messages from.
% mess_name - the name of the message to check for.
% mess_array  - cellarray of size(task_ids) where already received
%               messages are stored and not-received messages are
%               represented by empty cells
% Returns:
% receive_now  - boolean array of size task_ids, where true indicates
%                that message from correspondent task id is present and
%                can be read.
% message_names - cellarray of messages present in the system and available
%                 to receive
%
if ~exist('task_ids', 'var') || isempty(task_ids) ||...
        (ischar(task_ids) && strcmpi(task_ids,'all'))
    task_ids = 1:obj.numLabs;
    if numel(mess_array) ~= numel(task_ids) %
        not_this = task_id ~= obj.labIndex;
        if ~all(not_this);  task_ids = task_ids(not_this);
        end
    end
end
if numel(mess_array) ~= numel(task_ids) %
    error('MESSAGES_FRAMEWORK:invalid_argument',...
        ' size of messages array (%d) must be equal to size of task_id-s requested (%d)',...
        numel(mess_array),numel(task_ids))
end
if ischar(task_ids)
    error('MESSAGES_FRAMEWORK:invalid_argument',...
        ' Function accepts only one form of task_ids name: "all" but received unknown request: %s',...
        evalc('disp(task_ids)'));
end



% have it appeared?
[message_names,tid_from] = obj.probe_all(task_ids,mess_name);

mess_to_keep = cellfun(@(x)to_keep(x,obj.interrupt_chan_name_),mess_array,'UniformOutput',true);
% verify data messages already present not to force overwriting
% existing received data messages

receive_now = ismember(task_ids,tid_from);
new_mess_array = cell(1,numel(receive_now));
new_mess_array(receive_now) = message_names(:);



receive_now = receive_now & ~mess_to_keep;


message_names_array = cellfun(@extract_name,mess_array,'UniformOutput',false);
message_names_array(receive_now)  = new_mess_array(receive_now);



inrerrupt_name = obj.interrupt_chan_name_;
are_interrupts = ismember(message_names,inrerrupt_name);
if any(are_interrupts )
    interrupts_from = tid_from(are_interrupts);
    read_these = ismember(task_ids,interrupts_from );
    receive_now = receive_now | read_these;
    message_names_array(read_these)  = message_names(are_interrupts);
end


if obj.DEBUG_
    n_steps  = n_steps +1;
    disp([' Messages arrived at step ',num2str(n_steps), 'vs old mess received']);
    disp(receive_now);
    for i=1:numel(message_names)
        disp(message_names{i});
    end
end

function yes = to_keep(mess,interrupt)
if isempty(mess)
    yes = false;
    return
end
if strcmp(mess,interrupt)
    yes = true;
else
    yes = mess.is_blocking;
end
function name = extract_name(mess)
if isempty(mess)
    name = '';
else
    name=mess.mess_name;
end