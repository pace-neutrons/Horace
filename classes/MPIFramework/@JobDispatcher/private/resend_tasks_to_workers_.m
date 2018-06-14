function [outputs,n_failed,task_ids,obj]=...
    resend_tasks_to_workers_(obj,...
    task_class_name,common_params,loop_params,return_results,...
    keep_workers_running,task_query_time)
% restart parallel Matlab job started earlier by start_job command,
% providing it with new data. The cluster must be running

%
% Usage:
%>>jd = JobDispatcher();
%>>[outputs,n_failed,task_ids,jd]= jd.send_jobs(task_class_name,task_param_list,...
%                               [task_query_time])
%Where:
% job_class_name -- name of the class - child of jobExecutor,
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
% keep_workers_running -- if true, workers do not finish when job executors
%                   complete their jobs and stay active waiting for the next
%                   task submission.
% task_query_time    -- if present -- time interval to check if
%                   jobs are completed. By default, check every
%                   4 seconds
%
% Returns
% outputs   -- cellarray of outputs from each job.
%              empty if job does not return anything or Failed message for failed tasks
% n_failed  -- number of jobs that have failed.
%
% task_ids   -- list containing relation between task_id (task
%              number) and task parameters from
%              task_param_list, assigned to this job
%
%
% $Revision: 699 $ ($Date: 2018-02-08 17:40:52 +0000 (Thu, 08 Feb 2018) $)
%
%
if ~exist('keep_workers_running','var')
    keep_workers_running = false;
end
if exist('task_query_time','var') && ~isempty(task_query_time)
    obj.task_check_time  = task_query_time;
end
if isempty(obj.cluster_)
    error('JOB_DISPATCHER:runtime_error',...
        'Attempt to restart job when the cluster is not running');
end
if ~keep_workers_running
    clob = onCleanup(@()finalize_all(obj));
end


cluster_wrp = obj.cluster_;

[outputs,n_failed,task_ids,obj] = submit_and_run_job_(obj,task_class_name,...
    common_params,loop_params,return_results,...
    cluster_wrp,keep_workers_running);
% repeat finalize_all in case of dead clean-up objects stuck in class
% properties (issue with value class)
if ~keep_workers_running
    obj = obj.finalize_all();
end
