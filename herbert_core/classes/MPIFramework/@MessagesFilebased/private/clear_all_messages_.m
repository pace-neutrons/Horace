function clear_all_messages_(obj)
% delete all messages, directed to the specified lab
obj.persistent_fail_message_ = [];
%
finished = false;
pause(0.1); % give time to complete possible IO operations
while ~finished
    try
        [all_messages,mid_from] = list_all_messages_(obj,'all');
    catch ME
        if strcmp(ME.identifier,'MESSAGE_FRAMEWORK:cancelled')
            return;
        else
            rethrow(ME);
        end
    end
    if isempty(all_messages)
        finished = true;
        continue;
    end
    
    for i=1:numel(mid_from) % delete messages files sent to this lab.
        mess_fname = obj.job_stat_fname_(obj.labIndex,all_messages{i},mid_from(i),false);
        if is_file(mess_fname)
            delete(mess_fname);        
        end
        if is_file(mess_fname)
            unlock_(mess_fname);
        end
    end
end
% initialize counter of send/receive synchroneous data messages to 1; 
% the size of counters buffer is numLabs+1 as we may want to communicate
% with node 0;
obj.send_data_messages_count_ = ones(1,obj.numLabs+1);
obj.receive_data_messages_count_ = ones(1,obj.numLabs+1);

