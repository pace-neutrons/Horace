function [n_failed,outputs,task_ids,this]=send_tasks_to_workers_(this,...
    task_class_name,task_param_list,n_workers,varargin)
% send range of jobs to execute by external program
%
% Usage:
%>>jd = JobDispatcher();
%>>[n_failed,outputs,task_ids]= jd.send_jobs(task_class_name,task_param_list,...
%                               [number_of_workers,[task_query_time]])
%Where:
% task_param_list -- cellarray of structures containing the
%                   parameters of the tasks to run
% number_of_workers -- if present, number of Matlab sessions to
%                   start to deal with the tasks. By default,
%                   the number of sessions is equal to number
%                   of jobs
% task_query_time    -- if present -- time interval to check if
%                   jobs are completed. By default, check every
%                   4 seconds
%
% Returns
% n_failed  -- number of jobs that have failed.
%
% outputs   -- cellarray of outputs from each job.
%              Empty if jobs do not return anything
% task_ids   -- list containing relation between task_id (job
%              number) and job parameters from
%              task_param_list, assigned to this job
%
%
% $Revision: 699 $ ($Date: 2018-02-08 17:40:52 +0000 (Thu, 08 Feb 2018) $)
%
%
% identify number of jobs on the basis of number of parameters
% provided by input structure
%
% delete orphaned messages, which may belong to this framework, previous run
%
% clear all messages which may left in case of failure
clob = onCleanup(@()this.clear_all_messages());

[this,task_ids,worker_inits]=this.split_and_register_jobs(task_param_list,n_workers);

%par_in_cell = iscellstr(task_param_list); %this may be needed for task_parameter
%list being a cellarray of strings
% task id
for task_id=1:n_workers
    
    obj.running_tasks_{task_id} = taskController(task_id);    
    task_par_nums = (n_alloc_tasks(task_id)+1):(n_alloc_tasks(task_id)+each_task_npar(task_id));
    
    % Store task info for further usage and progress checking
    task = obj.running_tasks_{task_id};
    obj.running_tasks_{task_id} = task.set_task_id(task_id);
    %
    % generate first parameters string for the worker :
    this_task_param = task_param_list(task_par_nums);
    task_ids{task_id} = task_par_nums;
    
    taskControls{task_id} = obj.init_worker(task_id,this_task_param);
    % finalize task parameters string
    %---------------------------------------------------------------------
end


prog_start_str = this.worker_prog_string;
n_workers = numel(worker_inits);
%
processes = cell(1,n_workers);
%runtime = java.lang.Runtime.getRuntime();
task_common_str = {prog_start_str,'-nosplash','-nojvm','-r'};
for i=1:n_workers
    worker_init = worker_inits{i};
    worker_str = sprintf('worker(''%s'',''%s'');exit;',task_class_name,worker_init);
 
    task_str = [task_common_str,{worker_str}];
    this.
    % run external job
    %[nok,mess]=system(task_str);
    runtime = runtime.command(task_str);
    processes{i} = runtime.start();
    
    
    [completed,ok,mess] = check_task_completed_(processes{i},run_mess);
    if completed && ~ok
        error('JobDispatcher:starting_workers',[' Can not start worker N %d.',...
            ' Message returned: %s'],i,mess);
    end
end
clob1 = onCleanup(@()clear_all_processes(processes));
pause(1);
waiting_time = this.jobs_check_time;


count = 0;
[completed,n_failed,~,this]=check_jobs_status_(this,processes,run_mess);
while(~completed)
    if count == 0
        fprintf('**** Waiting for workers to finish their jobs ****\n')
        this.running_jobs_=print_task_progress_log_(this.running_jobs_);
    end
    pause(waiting_time);
    [completed,n_failed,all_changed,this]=check_jobs_status_(this,processes,run_mess);
    count = count+1;
    fprintf('.')
    if mod(count,19)==0 || all_changed
        fprintf('\n')
        this.running_jobs_=print_task_progress_log_(this.running_jobs_);
    end
end
fprintf('\n')
this.running_jobs_=print_task_progress_log_(this.running_jobs_);
%--------------------------------------------------------------------------
% retrieve outputs (if any)
outputs = cell(n_workers,1);
task_info=this.running_jobs_;
for ind = 1:n_workers
    if task_info{ind}.is_failed
        outputs{ind} = ['Failed, Reason: ',task_info{ind}.fail_reason];
    else
        outputs{ind} = task_info{ind}.outputs;
    end
end

function clear_all_processes(proc_list)

for i=1:numel(proc_list)
    proc_list{i}.destroy();
end
