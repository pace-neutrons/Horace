function worker_par_list = calc_job_indexes_(n_tasks,n_workers)
% calculate array of indexes, which divide n_tasks among n_workers
% calculate number of parameters, each worker would have


num_par_per_task = floor(n_tasks/n_workers);
if num_par_per_task<1; num_par_per_task =1; end

% split job parameters list between workers

% each task would process this number of parameters:
each_task_npar = ones(n_workers,1)*num_par_per_task;
%
n_alloc_tasks  = sum(each_task_npar);
if num_par_per_task*n_workers<n_tasks % spread the remaining tasks among the workers starting form the last
    for task_id=n_workers:-1:1
        if n_alloc_tasks<n_tasks
            each_task_npar(task_id) = each_task_npar(task_id)+1;
            n_alloc_tasks = n_alloc_tasks+1;
        else
            break;
        end
    end
end
n_alloc_tasks =[0;cumsum(each_task_npar)];


worker_par_list = zeros(2,n_workers);
for task_id=1:n_workers
    worker_par_list(:,task_id) = [(n_alloc_tasks(task_id)+1);n_alloc_tasks(task_id)+each_task_npar(task_id)];
end
