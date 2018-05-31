function [n_failed,outputs,task_par_id_per_worker,this]=...
    send_tasks_to_workers_(this,...
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

[n_workers,task_par_id_per_worker]=this.split_tasks(task_param_list,n_workers);

par_fm = parallel_config();
DEBUG_REMOTE = false;
%
for task_id=1:n_workers
    task_inputs = task_param_list(task_par_id_per_worker{task_id});
    
    th = par_fm.get_controller();
    %-----------------------------
    th = th.start_task(mf,task_class_name,task_id,task_inputs,DEBUG_REMOTE);
    %-----------------------------
    [ok,fail,err_mess] = th.is_running();
    if ~ok && fail
        error('JobDispatcher:starting_workers',[' Can not start worker N %d.',...
            ' Message returned: %s'],task_id,err_mess);
    end
    % wrap task into task controller to take care about it.
    tc = taskController(task_id,th);
    this.tasks_list_{task_id} = tc;
end
clob_tasks = onCleanup(@()kill_all_tasks(this.tasks_list_));
waiting_time = this.task_check_time;
pause(waiting_time );


count = 0;
[completed,n_failed,~,this]=check_tasks_status_(this);
while(~completed)
    if count == 0
        fprintf('**** Waiting for workers to finish their jobs ****\n')
        this.tasks_list_=print_tasks_progress_log_(this.tasks_list_);
    end
    pause(waiting_time);
    [completed,n_failed,all_changed,this]=check_tasks_status_(this);
    count = count+1;
    fprintf('.')
    if mod(count,19)==0 || all_changed % 19 is the length of task progress message
        fprintf('\n')
        this.tasks_list_=print_tasks_progress_log_(this.tasks_list_);
    end
end
fprintf('\n')
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

function kill_all_tasks(tasks_list)

for i=1:numel(tasks_list)
    tasks_list{i}.task_handle.stop_task();
end
