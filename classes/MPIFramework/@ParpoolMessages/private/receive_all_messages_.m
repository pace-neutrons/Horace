function   [all_messages,task_ids] = receive_all_messages_(obj,task_ids)
% retrieve all messages intended for jobs with id provided
%
if ~exist('task_ids','var')
    task_ids = [];
end

if isempty(task_ids)
    task_ids = 1:numlabs;
end


all_messages = cell(numel(task_ids),1);
[mess_names,tasks_present] = obj.probe_all(task_ids);
if isempty(mess_names)
    all_messages = {};
    return
end


for i=1:numel(task_ids)
    tid = tasks_present(i);
    if tid == 0
        task_ids(i) = 0;
        continue;
    end
    task_mess_names = mess_names{i};
    mes_tags = MESS_NAMES.mess_id(task_mess_names);
    for j =1:numel(mes_tags)
        try
            message = labReceive(tasks_present(i),mes_tags(j));
        catch Err
            error('PARPOOL_MESSAGES:runtime_error',...
                'Can not reveive existing message %s from task %d. Error: %s',...
                task_mess_names{j},tasks_present(i),Err.message);
        end
        if isempty(all_messages{i})
            all_messages{i} = message;
        else
            all_messages{i} = [{message},all_messages{i}];
        end
    end
end
