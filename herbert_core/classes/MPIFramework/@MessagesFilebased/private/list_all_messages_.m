function [all_messages,mid_from] = list_all_messages_(obj,task_ids_requested,mess_name_or_tag)
% list all messages sent to this task and retrieve the names
% for the lobs with id, provided as input.
%
% if no message is returned for a job, its name cell remains empty.
%
if ~exist('task_ids_requested', 'var')
    task_ids_requested = []; % list all available task_ids
elseif ischar(task_ids_requested) && strcmpi(task_ids_requested,'all')
    task_ids_requested = [];
end
if ischar(task_ids_requested)
    error('MESSAGES_FRAMEWORK:invalid_argument',...
        ' Function accepts only one form of task_ids input argument: "all" but received unknown request %s',...
        evalc('disp(task_ids_requested)'));
end

if ~exist('mess_name_or_tag', 'var')
    mess_tag_requested = [];
    mess_names_req = {};
elseif ischar(mess_name_or_tag)
    if isempty(mess_name_or_tag) || strcmpi(mess_name_or_tag,'any')
        mess_tag_requested = [];
        mess_names_req = {};
    else
        mess_tag_requested = MESS_NAMES.mess_id(mess_name_or_tag,obj.interrupt_chan_tag_);
        mess_names_req = mess_name_or_tag;
    end
elseif isnumeric(mess_name_or_tag)
    is = MESS_NAMES.tag_valid(mess_name_or_tag);
    if is
        mess_tag_requested = mess_name_or_tag;
        mess_names_req  = MESS_NAMES.mess_name(mess_tag_requested);
    else
        error('MESSAGES_FRAMEWORK:invalid_argument',...
            'one all of the tags among the tags provided in tags list is not recognized')
    end
else
end

if ischar(mess_names_req)
    mess_names_req = {mess_names_req};
end

mess_folder = obj.mess_exchange_folder;
if ~(is_folder(mess_folder)) % job was cancelled
    error('MESSAGE_FRAMEWORK:cancelled',...
        'Job with id %s has been cancelled. No messages folder exist',obj.job_id)
end

folder_contents = get_folder_contents_(obj,mess_folder);

[mess_names,mid_from,mid_to] = parse_folder_contents_(folder_contents,true);
if isempty(mess_names) % no messages
    all_messages = {};
    mid_from     = [];
    return
end

to_this = mid_to == obj.labIndex;
if ~any(to_this) % no messages directed to this lab
    all_messages = {};
    mid_from     = [];
    return
end
all_messages = mess_names(to_this);
mid_from     = mid_from(to_this);

if isempty(task_ids_requested) && isempty(mess_tag_requested) % all messages we need are listed
    [all_messages,mid_from] = select_unique_(obj,all_messages,mid_from);
    return;
end

if ~isempty(mess_tag_requested) % we have some particular message tags requested
    %mess_tags_present = MESS_NAMES.mess_id(all_messages);
    % allow to list fail message
    % interrupt message accepted even if not requested
    fail_list = obj.interrupt_chan_name_;
    if iscell(mess_names_req)
        rec_mess = [mess_names_req(:);fail_list];
    else
        rec_mess = {mess_names_req;fail_list};
    end
    
    is_requested  = ismember(all_messages,rec_mess);
    all_messages = all_messages(is_requested);
    mid_from     = mid_from(is_requested);
end

if ~isempty(task_ids_requested)
    is_requested = ismember(mid_from,task_ids_requested);
    all_messages = all_messages(is_requested);
    mid_from     = mid_from(is_requested);
end
[all_messages,mid_from] = select_unique_(obj,all_messages,mid_from);

function [all_messages,mid_from] = select_unique_(obj,all_messages,mid_from)
% from evert messages in every lab present, select only unique messages
fail_mess = obj.interrupt_chan_name_;


is_fail = ismember(all_messages,fail_mess);
if any(is_fail) % lets assume that only one fail message from one lab is possible
    fail_from = mid_from(is_fail); % it has to override other messages.
    fail_mess = all_messages(is_fail);
    
    all_labs = cell(1,max(mid_from));
    
    [mid_from,mu]=unique(mid_from);
    all_labs(mid_from) = all_messages(mu);
    all_labs(fail_from) = fail_mess;
    all_messages = all_labs(mid_from);
else
    [mid_from,mu]=unique(mid_from);
    all_messages = all_messages(mu);
end


