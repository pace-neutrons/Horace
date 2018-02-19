function  running_jobs_list=print_tasks_progress_log_(running_jobs_list)
% Method prints current state of all tasks in the framework
%
n_tasks = numel(running_jobs_list);
% retrieve the names of all messages, present in the system and intended
% for or originated from managed jobs.
% loop over all job descriptions and verify what these messages mean for
% jobs
for id=1:n_tasks
    job = running_jobs_list{id};
    log = job.get_task_info();
    job.state_changed = false;
    running_jobs_list{id} = job;
    fprintf('%s\n',log);    
end


