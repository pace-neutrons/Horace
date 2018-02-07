function [completed,n_failed,all_changed,this]= check_jobs_status_(this,processes,run_mess)
% Scan through the registered jobs list to identify the status of these jobs
%
% Report if all jobs were complteted or failed or how many jobs have
% actually failed
%
%
%
all_changed = false;
n_jobs = numel(this.running_jobs_);
n_failed = 0;
n_changed= 0;
n_completed=n_jobs;
% retrieve the names of all messages, present in the system and intended
% for || originated from managed jobs
all_messages = this.list_all_messages(1:n_jobs);
% loop over all job descriptions and verify what these messages mean for
% jobs
for id=1:n_jobs
    if isempty(this.running_jobs_(id)) %its a bug which should not happen
        continue;
    end
    [completed,ok,mess] = check_job_completed_(processes{id},run_mess);
        
    %
    job = this.running_jobs_{id};
    [job,is_running] = job.check_and_set_job_state(this,all_messages{id});
    if job.state_changed
        n_changed=n_changed+1;
    end
    if is_running
        n_completed = n_completed-1;
    end
    if job.is_failed
        n_failed = n_failed +1;
    end
    
    this.running_jobs_{id}=job;
end

if n_failed == n_jobs || n_completed == n_jobs
    completed = true;
else
    completed = false;
end
if n_changed == n_jobs
    all_changed = true;
end
