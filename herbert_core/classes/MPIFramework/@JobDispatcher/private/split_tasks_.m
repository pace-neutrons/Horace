function [worker_par_list,init_messages]=split_tasks_(...
    common_par,loop_par,return_outputs,n_workers)
% divide list of job parameters among given number of workers
%
%Inputs:
%job_param_list -- cellarray of classes or structures, containing task parameters.
%                  or number describing number of tasks.
%n_workers      -- number of workers to split job between workers
%
% returns: cell array of indices from job_param_list dedicated to run on a
% worker.
% init_messages -- cellarray of initMessages to send to each worker to
%                  start the particular part of the job for each worker
%
[n_workers,worker_par_list,is_list] = JobDispatcher.split_tasks_indices(loop_par,n_workers);

is_struct = isstruct(loop_par);
if is_struct
    field_names = fieldnames(loop_par);
    cell_data = struct2cell(loop_par);
end

init_messages = cell(1,n_workers);
for i=1:n_workers
    if is_list
        if is_struct
            param = split_struct(cell_data,field_names,worker_par_list{i});
            init_messages{i} = InitMessage(common_par,...
                param,return_outputs,1, is_list);
        else
            init_messages{i} = InitMessage(common_par,...
                loop_par(worker_par_list{i}),return_outputs,1, is_list);
        end
    else
        ind = worker_par_list{i};
        init_messages{i} = InitMessage(common_par,...
            ind(2),return_outputs,ind(1), is_list);
    end
end
end

function struct_par = split_struct(cell_data,field_names,array_cur)

n_fields = numel(field_names);
struct_par  = cell(n_fields,1);

for i=1:n_fields
    celd = cell_data{i};

    if size(celd,1) > size(celd,2)
        celd = celd';
    end

    if iscell(celd)
        struct_par{i} = celd(array_cur);
    elseif array_cur == 1
        struct_par{i} = celd;
    else
        error('HERBERT:JobDispatcher:invalid_argument',...
            'unsupported combination of cell data and cell indices');
    end
end

struct_par = cell2struct(struct_par,field_names);
end


