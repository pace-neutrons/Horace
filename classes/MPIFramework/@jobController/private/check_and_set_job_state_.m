function [obj,is_running] = check_and_set_job_state_(obj,mpi,new_message_name)
% find the job state as function of its current state and
% message it receives from mpi framework
%
if ~isempty(new_message_name) && strcmpi(new_message_name,'failed')
    [ok,err,mess] = mpi.receive_message(obj.job_id,'failed');
    if ~ok
        error('JOB_DISPATCHER:messages_error',err);
    end
    obj=obj.set_failed(mess.payload);
    is_running=false;
    obj.state_changed_ = true;
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
elseif obj.is_finished
    % should not receive anything from finished job. Let's ignore this
    % oddity
    is_running = false;
end

new_state = state2str_(obj);
if ~strcmp(cur_state,new_state)
    obj.state_changed_ = true;
end