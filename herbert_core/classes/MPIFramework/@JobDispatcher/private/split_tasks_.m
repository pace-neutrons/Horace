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
is_struct = false;
if isstruct(loop_par)
    is_struct = true;
    field_names = fieldnames(loop_par);
    sell_data = struct2cell(loop_par);
end

init_messages = cell(1,n_workers);
for i=1:n_workers
    if is_list
        if is_struct
            param = split_struct(sell_data,field_names,worker_par_list{i});
            init_messages{i} = InitMessage(common_par,...
                param,return_outputs,1);
        else
            init_messages{i} = InitMessage(common_par,...
                loop_par(worker_par_list{i}),return_outputs,1);
        end
    else
        ind = worker_par_list{i};
        init_messages{i} = InitMessage(common_par,...
            ind(2),return_outputs,ind(1));
    end
end

function struct_par = split_struct(cell_data,field_names,array_cur)
n_fields = numel(field_names);
struct_par  = cell(n_fields,1);
for i=1:n_fields
    celd =  cell_data{i};
    if size(celd,1)>    size(celd,2)
        celd = celd';
    end
    if iscell(celd)
        struct_par{i} = celd(array_cur);
    elseif array_cur == 1
        struct_par{i} = celd;
    else
        error('JOB_DISPATCHER:invalid_argument',...
            'unsupported combination of cell data and cell indexes');
    end
end
struct_par = cell2struct(struct_par,field_names);


function [n_workers,worker_par_list,is_list] = tasks_indexes(job_param_list,n_workers)
% get subtasks indexes, dividing input parameter list between defined number of workers.
%
if iscell(job_param_list) % the tasks are described by cellarray
    n_tasks = numel(job_param_list);
    is_list = true;
elseif isstruct(job_param_list) % array of structures
    fn = fieldnames(job_param_list);
    if ~isempty(fn)
        n_tasks = numel(job_param_list.(fn{1}));
        is_list = true;
    else
        error('JOB_DISPATCHER:invalid_argument',...
            ' job loop parameters contains empty structure');
    end
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
