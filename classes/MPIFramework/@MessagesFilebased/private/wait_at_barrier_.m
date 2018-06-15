function [ok,err,all_present]=wait_at_barrier_(obj,nothrow)
% inplement barrier for file-based messages by sending/receiving special
% barrier  messages
%
%fprintf(' Starting lab barier for lab N%d\n',obj.labIndex)
ok = true;
err = [];
if obj.labIndex == 1
    tasks = 2:obj.numLabs;
    [~,task_present] = obj.probe_all(tasks,'barrier');
    all_present = all(ismember(tasks,task_present));
    
    t0 = tic;
    while ~all_present
        pause(obj.time_to_react_);
        [~,task_present] = obj.probe_all(tasks,'barrier');
        
        all_present = all(ismember(tasks,task_present));
        if ~all_present
            ttl = toc(t0);
            if ttl> obj.time_to_fail
                if nothrow
                    ok=false;
                    err = 'Time of waiting at synchronization barrier has expired';
                else
                    error('FILEBASED_MESSAGES:rutime_error',...
                        'Time of waiting at synchronization barrier has expired');
                end
            end
        end
    end
    % wait for, receive and dicard all barrier messages to clear the file system
    [~,task_ids]=obj.receive_all('all','barrier');
    %is_failed = cellfun(@(nm)strcmp(nm.mess_name,'failed'),all_messages,'UniformOutput',true);
    
    mess = aMessage('barrier');
    for i=1:numel(task_ids)
        %if ~is_failed(i)
        obj.send_message(task_ids(i),mess);
        %end
    end
else
    obj.send_message(1,'barrier');
    [ok,err]=obj.receive_message(1,'barrier');
    if ok ~= MESS_CODES.ok
        if nothrow
            ok = false;
        else
            error('FILEBASED_MESSAGES:rutime_error',err)
        end
    else
        ok = true;
    end
    all_present = true;
end
%fprintf(' Completed lab barier for lab N%d\n',obj.labIndex)

