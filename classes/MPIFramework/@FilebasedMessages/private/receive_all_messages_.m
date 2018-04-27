function   [all_messages,task_ids] = receive_all_messages_(obj,task_ids,mess_name)
% retrieve all messages sent from jobs with id provided. if ids are empty,
% all messages, intended for this job.
%
if ~exist('task_ids','var')
    task_ids = [];
end
[message_names,task_ids] = list_all_messages_(obj,task_ids);

existing = cellfun(@(x)(~isempty(x)),message_names);
message_names = message_names(existing);
task_ids       = task_ids(existing);
all_messages = cell(numel(task_ids),1);

for i=1:numel(task_ids)
    mess_name = message_names{i};
    if iscell(mess_name)
        warning('FILEBASED_MESSAGES:invalid_message',...
            ['more than one message exist for the job with id: %d\n',...
            '         receving only one message and discarding others\n'],task_ids(i))
        for j=1:numel(mess_name)-1
            receive_message_(obj,task_ids(i),mess_name{j});
        end
        mess_name = mess_name{end};
    end
    [ok,err_mess,message]=receive_message_(obj,task_ids(i),mess_name);
    if ~ok
        warning('FILEBASED_MESSAGES:invalid_message',...
            'Can not retrieve message: %s, reported to framework as existing, Err: %s',...
            message_names{i},err_mess);
        message=[];
    end
    all_messages{i} = message;
end
