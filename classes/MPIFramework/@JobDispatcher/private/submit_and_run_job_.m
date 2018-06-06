function [outputs,n_failed,task_ids,obj] = submit_and_run_job_(obj,...
    task_class_name, common_params,loop_params,return_results,...
    cluster_wrp,keep_workers_running)
% submit parallel job to run on cluster
%
%Inputs:
% task_class_name - the name of jobExecutor class which does the requested
%                   work
% common_params   - the parameters, which are common for any loop
%                   iterations
% loop_params     - cellarray of parameters, to spread between workers or
%                   the number of internal loop iterations
% cluster_wrp     - the pointer for the class, responsible for
%                   the job submission and communications with tasks
% keep_workers_running - if true, current task completion does not finish
% parallel job and the job workers remain running and waiting for the next
%                   portion of the task to run
%
%
%
% $Revision: 699 $ ($Date: 2018-02-08 17:40:52 +0000 (Thu, 08 Feb 2018) $)
%

if ~keep_workers_running
    clob = onCleanup(@()delete(obj));
end

exit_worker_when_job_ends = cluster_wrp.exit_worker_when_job_ends;
n_workers                 = cluster_wrp.n_workers;
% access to class responsible for communications between head node
% and the pool of workers
mf                        = obj.mess_framework;
% split job
[task_ids,taskInitMessages]=...
    obj.split_tasks(common_params,loop_params,return_results,n_workers);
% build jobExecutor initialization message
je_init_message = mf.build_je_init(task_class_name,exit_worker_when_job_ends,keep_workers_running);

% submit info to cluster and start job
[cluster_wrp,completed] = cluster_wrp.start_job(je_init_message,taskInitMessages);
if completed
    % retrieve final results
    [outputs,n_failed]=  cluster_wrp.retrieve_results();
    return;
end

% wait until the job finishes
waiting_time = obj.task_check_time;
pause(waiting_time );

[completed,cluster_wrp]=cluster_wrp.check_progress();
cluster_wrp = cluster_wrp.display_progress();
% regularly checking the task state
while(~completed)
    pause(waiting_time);
    [completed,cluster_wrp]=cluster_wrp.check_progress();
    cluster_wrp = cluster_wrp.display_progress();
end
% retrieve final results
[outputs,n_failed]=  cluster_wrp.retrieve_results();
