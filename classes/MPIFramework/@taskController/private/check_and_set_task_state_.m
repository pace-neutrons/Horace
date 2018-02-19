function [obj,is_running] = check_and_set_task_state_(obj,mpi,new_message_name)
% find the job state as function of its current state and
% message it receives from mpi framework
%
[ok,fail,err_job] = obj.task_handle.is_running();
if ~ok
    pause(1)
    obj.is_failed_ = fail;
    if fail
        [ok,err_mess,mess] = mpi.receive_message(obj.task_id,'failed');
        if ok == MES_CODES.ok
            obj = obj.set_failed(mess.payload);
            new_message_name = '';
        elseif ok == MES_CODES.not_exist
            obj = obj.set_failed(sprintf('Task with id: %d crashed, Error: %s',...
                obj.task_id,err_job));
            new_message_name = '';
        else
            obj = obj.set_failed(sprintf('Task with id: %d crashed, Error receiving fail message: %s',...
                obj.task_id,err_mess));
        end
    else
        obj.is_running = false;
    end
end

if ~isempty(new_message_name) && strcmpi(new_message_name,'failed')
    [ok,err,mess] = mpi.receive_message(obj.task_id,'failed');
    if ok ~= MES_CODES.ok
        error('JOB_DISPATCHER:messages_error',err);
    end
    obj=obj.set_failed(mess.payload);
    is_running=false;
    return
end

cur_state = state2str_(obj);

if obj.is_starting
    [obj,is_running] = verify_starting_changes(obj,mpi,new_message_name);
elseif obj.is_running
    [obj,is_running] = verify_running_changes(obj,mpi,new_message_name);
elseif obj.is_failed
    is_running = false;
    % Job was thought failed but have recovered for some reason -- at least new
    % non-failed message have been received from "failed" state
    if ~isempty(new_message_name)
        [obj,is_running] = verify_running_changes(obj,mpi,new_message_name);
    end
elseif obj.is_finished % may be finished not by message but by framework control
    [obj,is_running] = verify_running_changes(obj,mpi,'completed')  ;
end

new_state = state2str_(obj);
if ~strcmp(cur_state,new_state)
    obj.state_changed_ = true;
end
