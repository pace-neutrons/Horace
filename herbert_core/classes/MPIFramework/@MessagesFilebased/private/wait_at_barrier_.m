function [ok,err,all_present]=wait_at_barrier_(obj,nothrow)
% inplement barrier for file-based messages by sending/receiving special
% barrier  messages
%
ok = true;
err = [];
if obj.labIndex == 1
    tasks = 2:obj.numLabs;
    [~,task_present] = list_specific_messages_(obj,tasks,'barrier',true);
    all_present = all(ismember(tasks,task_present));
    t0 = tic;
    % wait unill all barrier messages from slaves would appear
    while ~all_present
        pause(obj.time_to_react_);
        [~,task_present] = list_specific_messages_(obj,tasks,'barrier',true);
        all_present = all(ismember(tasks,task_present));
        if ~all_present
            ttl = toc(t0);
            if ttl> obj.time_to_fail
                if nothrow
                    ok=false;
                    err = 'Time of waiting at synchronization barrier has expired';
                else
                    error('FILEBASED_MESSAGES:rutime_error',...
                        'Timeout waiting for message "barrier" for task with id: %d',...
                        obj.labIndex);
                end
            end
        end
    end
    % dicard all existing barrier messages to clear the file system    
    for i=1:numel(tasks)
        reply = obj.mess_file_name(obj.labIndex,'barrier',tasks(i));
        delete(reply);
    end
    
    % send reply to slaves to report barrier release
    mess = aMessage('barrier');
    for i=1:numel(tasks)
        %if ~is_failed(i)
        obj.send_message(tasks(i),mess);
        %end
    end
else
    % send barrier message to master;
    obj.send_message(1,'barrier');
    % wait for master replying with barrier message 
    [~,task_present] = list_specific_messages_(obj,1,'barrier',true);
    reply_present = ~isempty(task_present);
    t0 = tic;
    while ~reply_present
        pause(obj.time_to_react_);
        
        [~,task_present] = list_specific_messages_(obj,1,'barrier',true);
        reply_present = ~isempty(task_present);
        if ~reply_present
            ttl = toc(t0);
            if ttl> obj.time_to_fail
                if nothrow
                    ok=false;
                    err = 'Time of waiting at synchronization barrier has expired';
                    return;
                else
                    error('FILEBASED_MESSAGES:rutime_error',...
                        'Timeout waiting for message "barrier" for task with id: %d',...
                        obj.labIndex);
                end
            end
        end
    end
    reply = obj.mess_file_name(obj.labIndex,'barrier',1);
    delete(reply);
    all_present = true;
end


