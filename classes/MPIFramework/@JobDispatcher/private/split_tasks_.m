function [n_workers,worker_par_list]=split_tasks_(obj,job_param_list,n_workers)
% divide list of job parameters among given number of workers
%
%Inputs:
%job_param_list -- cellarray of classes or structures, containing task parameters.
%n_workers      -- number of workers to split job between workers
%
% returns: cell array of indexes from job_param_list dedicated to run on a
% worker.
%
n_tasks = numel(job_param_list);
if n_workers> n_tasks
    n_workers = n_tasks;
end

num_par_per_task = floor(n_tasks/n_workers);
if num_par_per_task<1; num_par_per_task =1; end

% split job parameters list between workers
each_task_npar = ones(n_workers,1)*num_par_per_task;
n_alloc_tasks  = sum(each_task_npar);
if num_par_per_task*n_workers<n_tasks
    for task_id=1:n_workers
        if n_alloc_tasks<n_tasks
            each_task_npar(task_id) = each_task_npar(task_id)+1;
            n_alloc_tasks = n_alloc_tasks+1;
        else
            break;
        end
    end
end
n_alloc_tasks =[0;cumsum(each_task_npar)];


worker_par_list = cell(1,n_workers);
for task_id=1:n_workers
    
    task_par_nums = (n_alloc_tasks(task_id)+1):(n_alloc_tasks(task_id)+each_task_npar(task_id));
    worker_par_list{task_id}  = task_par_nums;
end
