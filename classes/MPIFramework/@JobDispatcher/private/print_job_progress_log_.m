function  print_job_progress_log_(this)
% Method prints current state of all jobs in the framework
%
n_jobs = numel(this.running_jobs_);
% retrieve the names of all messages, present in the system and intended
% for or originated from managed jobs.
% loop over all job descriptions and verify what these messages mean for
% jobs
for id=1:n_jobs
    log = this.running_jobs_(id).get_job_info();
    fprintf('%s\n',log);
end




