function     [obj,is_running] = verify_running_changes(obj,mpi,new_message_name)
% Job is running and received new message
% What to do
%
% here job_status file should indicate running state
is_running = true;
if isempty(new_message_name)
    % wait for some time for completed status file to appear
    if obj.reports_progress
        if obj.is_wait_time_exceeded()
            obj=obj.set_failed('Timeout waiting for "job continue running" or "completed" message');
            is_running = false;
        end
    else
        obj.waiting_count = obj.waiting_count+1;
        if obj.waiting_count > mpi.fail_limit
            obj=obj.set_failed('Timeout waiting for job_completed message');
            is_running = false;
        end
    end
elseif strcmpi(new_message_name,'started')
    % set state of job running; job may not report progress,
    %so have to wait indefinitely
    obj.is_running = true;
elseif strcmpi(new_message_name,'running')
    obj=get_progress_(obj,mpi,true);
elseif strcmpi(new_message_name,'completed')
    obj = get_output_(obj,mpi);
    is_running = false;
else
    warning('JOB_CONTROLLER:job_status',...
        'Job with id: %d. Unknown job control state: %s',...
        obj.job_id,new_message_name);
    is_running = false;
end


