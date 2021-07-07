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
    if ~exist('keep_workers_running', 'var')
        keep_workers_running = false;
    end

    if exist('task_query_time', 'var') && ~isempty(task_query_time)
        obj.task_check_time  = task_query_time;
    end

    mf = obj.mess_framework_;

    % if loop param defines less loop parameters then there are workers requested,
    % the number of workers will be decreased.
    n_workers = check_loop_param(loop_params,n_workers);

    % indicate new cluster created
    obj.job_is_starting_ = true;
    % retrieve instance of the cluster factory
    par_fc = MPI_clusters_factory.instance();
    % retrieve and initialize the cluster, defined by current configuration
    cluster_wrp = par_fc.get_initialized_cluster(n_workers,mf);

    % verify if the cluster have started and report it was.
    [cluster_wrp,ok] = cluster_wrp.wait_started_and_report(obj.task_check_time);
    if ~ok
        n_restart_attempts = 5;
        ic = 0;
        pc = parallel_config;

        while ~ok && ic <n_restart_attempts
            cluster_wrp.display_progress(...
                sprintf(' Trying to restart parallel cluster for the %d time',ic+1));

            job_info = mf.initial_framework_info;
            cluster_wrp.finalize_all(); % will destroy current mf
            % Reinitialize mf and create job folder
            mf = MessagesFilebased(job_info);
            if ~isempty(pc.shared_folder_on_local)
                mf.mess_exchange_folder = pc.shared_folder_on_local;
            end

            obj.mess_framework_ = mf;

            cluster_wrp = par_fc.get_initialized_cluster(n_workers,mf);
            [cluster_wrp,ok] = cluster_wrp.wait_started_and_report(obj.task_check_time);
            ic= ic+1;
        end
        if ~ok
            error('HERBERT:JobDispatcher:runtime_error',...
                  ' Can not start parallel cluster %s after %d attempts. Parallel job aborted',...
                  class(cluster_wrp),n_restart_attempts+1);
        end
    end

    if keep_workers_running % store cluster pointer for job resubmission
        obj.cluster_       = cluster_wrp;
        obj.job_destroyer_ = onCleanup(@()finalize_all(cluster_wrp));
    else % clear cluster on exit
        clob_mf = onCleanup(@()finalize_all(cluster_wrp));
    end

    [outputs,n_failed,task_ids,obj] = submit_and_run_job_(obj,task_class_name,...
                                                      common_params,loop_params,return_results,...
                                                      cluster_wrp,keep_workers_running);
    if exist('clob_mf', 'var')
        clear clob_mf;
    end

end

function n_wk = check_loop_param(loop_param,n_workers)
    % Available number of workers
    n_wk = n_workers;

    if ~isscalar(loop_param)
        n_jobs = numel(loop_param);
    elseif isscalar(loop_param) && isnumeric(loop_param)
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
              'Unknown type of loop_param variable: %s', class(loop_param));
    end

    % Clip workers to number of jobs
    if n_wk > n_jobs
        n_wk = n_jobs;
    end

end
