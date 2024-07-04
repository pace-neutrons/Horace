function [n_workers,worker_par_list,is_list] = split_tasks_indices_(job_param_list,n_workers)
% get indices of the input array, cellarray or structure which would properly divide
% inputs among specifed number of workers (parts).
%
% Inputs:
% job_param_list   -- array, cellarray or structural array
%                     to divide into parts.
% n_workers        -- number of parts to divide job_param_list
%
% Outputs:
% n_workers        -- actual number of parts the input array
%                     was divided into. Normally should be
%                     equal to n_workers, but if inputs have
%                     fewer elements than input n_workers,
%                     usually equal to number of elements in
%                     input.
% worker_par_list  -- cellarray containing n_workers - elements.
%                     Each cellarry element would contain
%                     information about part of the
%                     job_param_list which should be allocated
%                     to appropriate worker.
% is_list          -- boolean which is true if input array is
%                     divided into array of indices or false if
%                     it is divided into parirs containing
%                     numbers of first and last contributing
%                     elements.
%
if isscalar(job_param_list) && isnumeric(job_param_list)
    n_tasks = job_param_list;
    is_list = false;
elseif isstruct(job_param_list) % array of structures
    fn = fieldnames(job_param_list);
    if ~isempty(fn)
        n_tasks = numel(job_param_list.(fn{1}));
        is_list = true;
    else
        error('HERBERT:JobDispatcher:invalid_argument',...
            ' job loop parameters contains empty structure');
    end
else
    n_tasks = numel(job_param_list);
    is_list = true;
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
        if n_alloc_tasks >= n_tasks
            break;
        end
        each_task_npar(task_id) = each_task_npar(task_id)+1;
        n_alloc_tasks = n_alloc_tasks+1;
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
end

