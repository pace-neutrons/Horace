function [n_failed,outputs,task_par_id_per_worker,this]=...
    send_tasks_to_workers_(this,...
    task_class_name,common_params,loop_params,return_results,n_workers,task_query_time)
% send range of jobs to execute by external program
%
% Usage:
%>>jd = JobDispatcher();
%>>[n_failed,outputs,task_ids]= jd.send_jobs(task_class_name,task_param_list,...
%                               [number_of_workers,[task_query_time]])
%Where:
% job_class_name -- name of the class - chield of jobExecutor,
%                   which will process task on a separate worker
% common_params  -- a structure, containing the parameters, common
%                   for any loop iteration
% loop_params    -- either cellarray of structures, specific
%                   with each cell specific to a loop iteration
%                   or the number of iterations to do over
%                   common_params (which may depend on the
%                   iteration number)
% number_of_workers -- number of Matlab sessions to
%                    process the tasks
% task_query_time    -- if present -- time interval to check if
%                   jobs are completed. By default, check every
%                   4 seconds
%
% Returns
% n_failed  -- number of jobs that have failed.
%
% outputs   -- cellarray of outputs from each job.
%              Empty if jobs do not return anything
% task_ids   -- list containing relation between task_id (task
%              number) and task parameters from
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
mf = this.mess_framework_;
clob_mf = onCleanup(@()mf.finalize_all());

% initialize cluster
par_fm = parallel_config();
cluster = par_fm.get_cluster_wrapper(n_workers,mf);

% split job
[n_workers,InitMessages]=...
    this.split_tasks(common_params,loop_params,return_results,n_workers);
% and send appropriate parts to workers
for task_id=1:n_workers
    [ok,err]=mf.send_message(task_id,InitMessages{task_id});
    if ok ~= MESS_CODES.ok
        error('JOB_DISPATCHER:runtime_error',...
            ' Error %s sendfing init message to task %d',err,task_id);
    end
end
%je_init_message = mf.build_je_init(JE_className,exit_on_completion,keep_worker_running);
je_init_message = mf.build_je_init(task_class_name,true,false);
cluster = cluster.start_job(je_init_message,@worker,task_init_mess);

if exist('task_query_time','var') && ~isempty(task_query_time)
    this.task_check_time  = task_query_time;
end
waiting_time = this.task_check_time;
pause(waiting_time );



[completed,cluster]=cluster.check_job_status();
cluster = cluster.display_progress();
%
while(~completed)    
    pause(waiting_time);
    [completed,cluster]=cluster.check_job_status();    
    cluster = cluster.display_progress();   
end
[n_failed,outputs,task_par_id_per_worker] = cluster.return_results();

this.tasks_list_=print_tasks_progress_log_(this.tasks_list_);
%--------------------------------------------------------------------------
% retrieve outputs (if any)
outputs = cell(n_workers,1);
task_info=this.tasks_list_;
for ind = 1:n_workers
    if task_info{ind}.is_failed
        outputs{ind} = ['Failed, Reason: ',task_info{ind}.fail_reason];
    else
        outputs{ind} = task_info{ind}.outputs;
    end
end
    if count == 0
        fprintf('**** Waiting for workers to finish their jobs ****\n')
        this.tasks_list_=print_tasks_progress_log_(this.tasks_list_);
    end

function kill_all_tasks(tasks_list)

for i=1:numel(tasks_list)
    tasks_list{i}.task_handle.stop_task();
end
