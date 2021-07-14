function [all_messages,mid_from] = list_specific_messages_(obj,task_ids_requested,mess_name_or_tag,ignore_interrupts)
% list messages with specific name sent to this task and retrieve the names
% for the jobs with id, provided as input.
%
% if no message is returned for a job, its name cell remains empty.

%
if ~exist('task_ids_requested', 'var') || isempty(task_ids_requested)
    task_ids_requested = 1:obj.numLabs; % list all available task_ids
elseif ischar(task_ids_requested) && strcmpi(task_ids_requested,'all')
    task_ids_requested = 1:obj.numLabs;
end
if nargin<4
    ignore_interrupts = false;
end
if ischar(task_ids_requested)
    error('LIST_MESSAGES:invalid_argument',...
        ' Function accepts only one form of task_ids input argument: "all" but received unknown request %s',...
        evalc('disp(task_ids_requested)'));
end

% No harm in sending filebased messages to itself, especially as
% list_all_messages_ accepts them but better to keep the common interface
% with other frameworks
not_this = task_ids_requested ~= obj.labIndex;
task_ids_requested = task_ids_requested(not_this);

if ~exist('mess_name_or_tag', 'var')
    error('FILEBASED_MESSAGES:invalid_argument',...
        'one all of the tags among the tags provided in tags list is not recognized')
end

if iscell(mess_name_or_tag)
    error('FILEBASED_MESSAGES:invalid_argument',...
        'this message accepts single message name only');
end
if isnumeric(mess_name_or_tag)
    mess_name_or_tag = MESS_NAMES.mess_name(mess_name_or_tag);
end

mess_folder = obj.mess_exchange_folder;
if ~(is_folder(mess_folder)) % job was cancelled
    error('MESSAGES_FRAMEWORK:cancelled',...
        'Job with id %s has been cancelled. No messages folder exist',obj.job_id)
end
% find nolocked messages:
[all_messages,mid_from] = find_messages_with_name_(obj,task_ids_requested,mess_name_or_tag,false);
if ignore_interrupts
    return;
end

%
% check interrupts
% -------------------------------------------------------------------------
interrupt_name = obj.interrupt_chan_name_ ;


any_interrupt   = false(1,max(task_ids_requested));
interrupt_found = cell(1,max(task_ids_requested));

[interrupt_messages,interrupt_present] = find_messages_with_name_(obj,task_ids_requested,interrupt_name,true);
if ~isempty(interrupt_messages)
    any_interrupt(interrupt_present) = true;
    interrupt_found(interrupt_present) = {interrupt_name};
end

% -------------------------------------------------------------------------
net_range = max(task_ids_requested);
net_range = 1:net_range;
if any(any_interrupt) % some interrupts are present, mix them with real messages
    if ~isempty(all_messages) % combine messages and interrupts
        mess = cell(1,numel(net_range));
        from_all_labs = false(1, numel(net_range));
        mess(mid_from)= all_messages(:);
        from_all_labs(mid_from) = true;
        mess(any_interrupt) = interrupt_found(any_interrupt);
        from_all_labs = from_all_labs | any_interrupt;
        all_messages = mess(from_all_labs);
        mid_from  = net_range(from_all_labs);
    else
        all_messages = interrupt_found(any_interrupt);
        mid_from     = net_range(any_interrupt);
    end
end



