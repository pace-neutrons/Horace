function [outputs,n_failed,task_ids,obj]=...
    send_tasks_to_workers_(obj,...
    task_class_name,common_params,loop_params,return_results,...
    n_workers,keep_workers_running,task_query_time)
% send parallel job to be executed by Matlab cluster
%
% Usage:
%>>jd = JobDispatcher();
%>>[outputs,n_failed,task_ids,jd]= jd.send_jobs(task_class_name,task_param_list,...
%                               [number_of_workers,[task_query_time]])
%Where:
% job_class_name -- name of the class - child of jobExecutor,
%                   which will process task on a separate worker
% common_params  -- a structure, containing the parameters, common
%                   for any loop iteration
% loop_params    -- either cellarray of structures, with
%                   each cell specific to a single loop iteration
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
% $Revision:: 830 ($Date:: 2019-04-08 17:54:30 +0100 (Mon, 8 Apr 2019) $)
%
%
if ~exist('keep_workers_running','var')
    keep_workers_running = false;
end

if exist('task_query_time','var') && ~isempty(task_query_time)
    obj.task_check_time  = task_query_time;
end

mf = obj.mess_framework_;

% if loop param defines less loop parameters then there are workers requested, 
% the number of workers will be decreased.
n_workers = check_loop_param(loop_params,n_workers);

% indicate new cluster created
obj.job_is_starting_ = true;
% initialize cluster, defined by current configuration
par_fm = parallel_config();
cluster_wrp = par_fm.get_cluster_wrapper(n_workers,mf);

if keep_workers_running % store cluster pointer for job resubmission
    obj.cluster_       = cluster_wrp;
    obj.job_destroyer_ = onCleanup(@()finalize_all(cluster_wrp));
else % clear cluster on exit
    clob_mf = onCleanup(@()finalize_all(cluster_wrp));
end

[outputs,n_failed,task_ids,obj] = submit_and_run_job_(obj,task_class_name,...
    common_params,loop_params,return_results,...
    cluster_wrp,keep_workers_running);
if exist('clob_mf','var')
    clear clob_mf;
end


function n_wk = check_loop_param(loop_param,n_workers)
n_wk = n_workers;
if iscell(loop_param)
    n_jobs = numel(loop_param);
elseif isnumeric(loop_param)
    n_jobs = loop_param;
elseif isstruct(loop_param)
    fn = fieldnames(loop_param);
    par1 = loop_param.(fn{1});
    if iscell(par1)
        n_jobs = numel(par1);
    else
        n_jobs = 1;
    end
else
    error('JOB_DISPATCHER:invalid_argument',...
        'Unknown type of loop_param variable');
end
if n_wk > n_jobs
    n_wk  = n_jobs;
end
