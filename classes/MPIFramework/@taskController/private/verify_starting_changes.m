function [obj,is_running] = verify_starting_changes(obj,mpi,new_message_name)
% job is starting and new message has been received
% What to do
%
is_running = true;
if isempty(new_message_name)
    obj.waiting_count_ = obj.waiting_count_+1;
    if obj.waiting_count_ > mpi.fail_limit
        obj=obj.set_failed('Timeout waiting for job_started message. Error in JobExecutor.init_worker');
    end
elseif strcmpi(new_message_name,'starting')
    obj.waiting_count_ = obj.waiting_count_+1;
    if obj.waiting_count_ > mpi.fail_limit
        is_running = false;
        obj=obj.set_failed('Timeout waiting for job_started message');
    end
elseif strcmpi(new_message_name,'started')
    % job may not report status
    obj.is_running = true;
elseif strcmpi(new_message_name,'running')
    obj= get_progress_(obj,mpi,false);
    % get job logging status
elseif strcmpi(new_message_name,'completed')
    obj = get_output_(obj,mpi);
    is_running = false;
else
    warning('TASK_CONTROLLER:task_status',...
        'Task with id: %d. Unknown task control state: %s',...
        obj.task_id,new_message_name);
    is_running = false;
end

