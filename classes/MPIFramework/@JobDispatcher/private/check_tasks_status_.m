function [completed,n_failed,all_changed,this]= check_tasks_status_(this)
% Scan through the registered jobs list to identify the status of these jobs
%
% Report if all jobs were complteted or failed or how many jobs have
% actually failed
%
%
%
all_changed = false;
n_jobs = numel(this.tasks_list_);
n_failed = 0;
n_changed= 0;
n_completed=n_jobs;
% retrieve the names of all messages, present in the system and intended
% for || originated from managed jobs
mpi  = this.mess_framework_;
all_messages = mpi.probe_all(1:n_jobs);
% loop over all job descriptions and verify what these messages mean for
% jobs
for id=1:n_jobs
    if isempty(this.tasks_list_(id)) %its a bug which should not happen
        continue;
    end
    task = this.tasks_list_{id};
    if task.is_finished && ~task.is_failed
        continue;
    end
    %
    if isempty(all_messages)  % no reply from the task during the query interval
        % depending on the job state, start counting failure
        [task,is_running] = task.check_and_set_task_state(mpi,'');
    else
        [task,is_running] = task.check_and_set_task_state(mpi,all_messages{id});
    end
    if task.state_changed
        n_changed=n_changed+1;
    end
    if is_running
        n_completed = n_completed-1;
    end
    if task.is_failed
        n_failed = n_failed +1;
    end
    this.tasks_list_{id}=task;
end

if n_failed == n_jobs || n_completed == n_jobs
    completed = true;
else
    completed = false;
end
if n_changed == n_jobs
    all_changed = true;
end
