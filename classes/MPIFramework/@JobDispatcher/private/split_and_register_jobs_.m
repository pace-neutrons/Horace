function [obj,job_ids,worker_controls]=split_and_register_jobs_(obj,job_param_list,n_workers)
% given list of job parameters, divide jobs between workers, initialize
% workers and register job info in the class for further job control

n_jobs = numel(job_param_list);
if n_workers> n_jobs
    n_workers = n_jobs;
end

step = ceil(n_jobs/n_workers);
if step<1; step =1; end

js = jobController(0);
obj.running_jobs_ = cell(n_workers,1);
for i=1:n_workers
    obj.running_jobs_{i} = js;
end
%else
%    obj.running_jobs_=repmat(js,n_workers,1);
%end
job_ids = cell(n_workers,1);
worker_controls = cell(n_workers,1);

%par_in_cell = iscellstr(job_param_list); %this may be needed for job_parameter
%list being a cellarray of strings

% job id
job_id = 0;
for ic=1:step:n_jobs
    job_id = job_id+1;
    
    job_par_nums = ic:ic+step-1;
    valid_nums   = job_par_nums<=n_jobs;
    job_par_nums = job_par_nums(valid_nums);
    
    % Store job info for further usage and progress checking
    job = obj.running_jobs_{job_id};
    obj.running_jobs_{job_id} = job.set_job_id(job_id);
    %
    % generate first parameters string for the worker :
    this_job_param = job_param_list(job_par_nums);
    job_ids{job_id} = job_par_nums;
    
    worker_controls{job_id} = obj.init_worker(job_id,this_job_param);
    % finalize job parameters string
    %---------------------------------------------------------------------
end
if job_id<n_workers
    obj.running_jobs_=obj.running_jobs_(1:job_id);
    job_ids = job_ids(1:job_id);
    worker_controls = worker_controls(1:job_id);
end
