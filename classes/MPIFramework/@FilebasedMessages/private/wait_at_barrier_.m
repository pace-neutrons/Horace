function all_present=wait_at_barrier_(obj)
% inplement barrier for file-based messages by sending/receiving special
% barrier  messages
%
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
                error('FILEBASED_MESSAGES:rutime_error',...
                    'Time of waiting at synchronization barrier has expired');
            end
        end
    end
    % receive and dicard all barrier messages to clear file system
    obj.receive_all('all','barrier');
    mess = aMessage('barrier');
    for i=2:obj.numLabs
        obj.send_message(i,mess);
    end
else
    obj.send_message(1,'barrier');
    [ok,err]=obj.receive_message(1,'barrier');
    if ok ~= MESS_CODES.ok
        error('FILEBASED_MESSAGES:rutime_error',err)
        
    end
    all_present = true;
end


