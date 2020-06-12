function [all_messages,mid_from] = list_specific_messages_(obj,task_ids_requested,mess_name_or_tag)
% list all messages sent to this task and retrieve the names
% for the lobs with id, provided as input.
%
% if no message is returned for a job, its name cell remains empty.
%
if ~exist('task_ids_requested','var') || isempty(task_ids_requested)
    task_ids_requested = 1:obj.numLabs; % list all available task_ids
elseif ischar(task_ids_requested) && strcmpi(task_ids_requested,'all')
    task_ids_requested = 1:obj.numLabs;
end
not_this = task_ids_requested ~= obj.labIndex;
task_ids_requested = task_ids_requested(not_this);

if ~exist('mess_name_or_tag','var')
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
if ~(exist(mess_folder,'dir')==7) % job was canceled
    error('FILEBASED_MESSAGES:runtime_error',...
        'Job with id %s has been canceled. No messages folder exist',obj.job_id)
end
% find nolocked messages:
[all_messages,mid_from] = find_messages_with_name_(obj,task_ids_requested,mess_name_or_tag,false);
%
% check interrupts
% -------------------------------------------------------------------------
interrupt_names = MESS_NAMES.instance().interrupts;
if ~iscell(interrupt_names)
    interrupt_names = {interrupt_names};
end


any_interrupt   = false(1,max(task_ids_requested));
interrupt_found = cell(1,max(task_ids_requested));
for i=1:numel(interrupt_names )
    [interrupt_messages,interrupt_present] = find_messages_with_name_(obj,task_ids_requested,interrupt_names{i},true);
    if ~isempty(interrupt_messages)
        any_interrupt(interrupt_present) = true;
        interrupt_found(interrupt_present) = interrupt_messages(:);
    end
end
% -------------------------------------------------------------------------
if any(any_interrupt) % some interrupts are present, mix them with real messages
    if ~isempty(all_messages) % combine messages and interrupts
        mess = cell(1,max(task_ids_requested));
        from_all_labs = false(1, max(task_ids_requested));
        mess(mid_from)= all_messages(:);
        from_all_labs(mid_from) = true;
        mess(any_interrupt) = interrupt_found(any_interrupt);
        from_all_labs = from_all_labs | any_interrupt;
        all_messages = mess(from_all_labs);
        mid_from = 1:max(task_ids_requested);
        mid_from  = mid_from(from_all_labs);
    else
        all_messages = interrupt_found(any_interrupt);
        mid_from     = task_ids_requested(any_interrupt);
    end
end
