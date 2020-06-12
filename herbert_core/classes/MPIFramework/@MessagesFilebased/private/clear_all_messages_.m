function clear_all_messages_(obj)
% delete all messages, directed to the specified lab
obj.persistent_fail_message_ = [];
%
finished = false;
pause(0.5); % give time to complete possible IO operations
while ~finished
    try
        [all_messages,mid_from] = list_all_messages_(obj);
    catch ME
        if strcmp(ME.identifier,'MESSAGE_FRAMEWORK:canceled')
            return;
        else
            rethrow(ME);
        end
    end
    if isempty(all_messages)
        finished = true;
        continue;
    end
    
    for i=1:numel(mid_from) % delete messages files
        mess_fname = obj.job_stat_fname_(obj.labIndex,all_messages{i},mid_from(i));
        delete(mess_fname);
    end
end
