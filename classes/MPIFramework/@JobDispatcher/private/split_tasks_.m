function [worker_par_list,init_messages]=split_tasks_(...
    common_par,loop_par,return_outputs,n_workers)
% divide list of job parameters among given number of workers
%
%Inputs:
%job_param_list -- cellarray of classes or structures, containing task parameters.
%                  or number describing number of tasks.
%n_workers      -- number of workers to split job between workers
%
% returns: cell array of indexes from job_param_list dedicated to run on a
% worker.
% init_messages -- cellarray of initMessages to send to each worker to
%                  start the particular part of the job for each worker
%
[n_workers,worker_par_list,is_list] = tasks_indexes(loop_par,n_workers);

init_messages = cell(1,n_workers);
for i=1:n_workers
    if is_list
        init_messages{i} = InitMessage(common_par,...
            loop_par(worker_par_list{i}),return_outputs,1);
    else
        ind = worker_par_list{i};
        init_messages{i} = InitMessage(common_par,...
            ind(2),return_outputs,ind(1));
    end
end




function [n_workers,worker_par_list,is_list] = tasks_indexes(job_param_list,n_workers)
% get subtasks indexes, dividing input parameter list between defined number of workers.
%
if iscell(job_param_list) % the tasks are described by cellarray
    n_tasks = numel(job_param_list);
    is_list = true;
elseif isnumeric(job_param_list)
    n_tasks = job_param_list;
    is_list = false;
end
if n_workers> n_tasks
    n_workers = n_tasks;
end

num_par_per_task = floor(n_tasks/n_workers);
if num_par_per_task<1; num_par_per_task =1; end

% split job parameters list between workers
each_task_npar = ones(n_workers,1)*num_par_per_task;
n_alloc_tasks  = sum(each_task_npar);
if num_par_per_task*n_workers<n_tasks
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


worker_par_list = cell(1,n_workers);
for task_id=1:n_workers
    if is_list
        task_par_nums = (n_alloc_tasks(task_id)+1):(n_alloc_tasks(task_id)+each_task_npar(task_id));
        worker_par_list{task_id}  = task_par_nums;
    else
        worker_par_list{task_id} = [(n_alloc_tasks(task_id)+1),each_task_npar(task_id)];
    end
end
