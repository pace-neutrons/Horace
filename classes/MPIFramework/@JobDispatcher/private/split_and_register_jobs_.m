function [obj,job_ids,worker_controls]=split_and_register_jobs_(obj,job_param_list,n_workers)
% given list of job parameters, divide jobs between workers, initialize
% workers and register job info in the class for further job control
%
%Inputs:
%job_param_list -- cellarray of classes or structures, containing job parameters.
%n_workers      -- number of workers to split jobs between workers
%
n_jobs = numel(job_param_list);
if n_workers> n_jobs
    n_workers = n_jobs;
end

num_par_per_job = floor(n_jobs/n_workers);
if num_par_per_job<1; num_par_per_job =1; end

% split job parameters list between workers
each_job_npar = ones(n_workers,1)*num_par_per_job;
n_alloc_jobs  = sum(each_job_npar);
if num_par_per_job*n_workers<n_jobs
    for i=1:n_workers
        if n_alloc_jobs<n_jobs
            each_job_npar(i) = each_job_npar(i)+1;
            n_alloc_jobs = n_alloc_jobs+1;
        else
            break;
        end
    end
end
n_alloc_jobs =[0;cumsum(each_job_npar)];


js = jobController(0);
obj.running_jobs_ = cell(n_workers,1);
job_ids = cell(n_workers,1);
worker_controls = cell(n_workers,1);

%par_in_cell = iscellstr(job_param_list); %this may be needed for job_parameter
%list being a cellarray of strings
% job id
for job_id=1:n_workers
    
    obj.running_jobs_{job_id} = js;    
    job_par_nums = (n_alloc_jobs(job_id)+1):(n_alloc_jobs(job_id)+each_job_npar(job_id));
    
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
% if job_id<n_workers
%     obj.running_jobs_=obj.running_jobs_(1:job_id);
%     job_ids = job_ids(1:job_id);
%     worker_controls = worker_controls(1:job_id);
% end
