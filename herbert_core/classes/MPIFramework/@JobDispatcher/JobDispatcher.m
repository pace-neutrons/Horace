classdef JobDispatcher
    % The class to run and control Herbert MPI jobs which are the children
    % of JobExecutor class.
    %
    % Allow user to run multi-session or MPI jobs, defined by the
    % child classes of the JobExecutor class.
    %
    % The parallel job is run on a Cluster, selected by parallel_config
    % configuration.
    %
    % JobDispatcher: Main properties and methods
    % ---------------------------------------------
    % Job Description and control properties:
    %
    % job_id         - String describing the current job
    % mess_framework - Instance of the file-based messages framework used
    %                  for communications with the cluster
    % cluster        - Read-only instance of a <a href="matlab:help('ClusterWrapper');">ClusterWrapper</a>
    %                  controlling a parallel job
    % is_initialized - true if jobDispatcher already controls a cluster.
    %
    % ---------------------------------------------
    % Job Timing:
    %
    % task_check_time - how often (in seconds) job dispatcher should query the task status
    % task_wait_time  - Short drop-out time (in seconds) for querying task status
    %
    % fail_limit      - number of times to try an action before deciding a
    %                   job has failed
    % time_to_fail    - time interval to wait until job which do not send
    %                   any messages from cluster is considered failed.
    %
    % ---------------------------------------------------------------------
    % JobDispatcher methods:
    %
    % start_job    - Start cluster and initialize parallel job to be executed
    %                by the cluster.
    % restart_job  - Restart parallel Matlab job started earlier by start_job
    % finalize_all - Stop cluster and parallel processes and clear all messages.
    %
    % Helpers:
    % display_fail_job_results - Auxiliary method to display job results
    %               if the job has failed.
    % split_tasks - Divide list of job parameters among given number of
    %               workers and generate list of init messages for the
    %               subtasks
    %
    properties(Dependent)
        % The string with running job id, i.e. the name, which describes
        % the job, and distinguishes it from any other jobs running
        % on a system. Normally, a folder with this name exists on a
        % shared file system and all file-based messages related to
        % controlling this job are relayed through this folder.
        job_id;

        % The instance of the file-based messages framework used for
        % exchange between logon node and the cluster. Used for providing
        % initialization information for the job, receiving log messages
        % from node-1 and returning some calculations' results
        mess_framework;

        % Exposes read access to parallel cluster, instance of a
        % <a href="matlab:help('ClusterWrapper');">ClusterWrapper</a> class
        % to run a parallel job.
        cluster;

        % True if jobDispatcher already controls a cluster
        % so the next job is executed on existing cluster
        % rather then starting a new one.
        % False if the cluster is not running and needs to start up.
        is_initialized;
        % -----------------------------------------------------------------

        % how often (in seconds) JobDispatcher should query the task status
        task_check_time;

        % Short drop-out time (in seconds) for querying task status
        task_wait_time;

        % Number of times to try action until deciding the action has failed
        fail_limit;

        % Time interval to wait until job which is not sending any messages
        % from the cluster is considered failed (and should be terminated)
        time_to_fail;
    end

    properties(Access=protected, Hidden = true)
        % How often (in seconds) JobDispatcher should display the task status
        task_check_time_ = 4;

        % Short drop-out time (in seconds) for querying task status
        task_wait_time_ = 0.1;

        fail_limit_ = 100; % number of times to try for changes in job status file until
                           % decided the job has failed

        % The framework to exchange messages with the tasks
        mess_framework_;

        time_to_fail_  = 300; %300sec, 5 min

        % Holder for initiated cluster for resubmitting jobs
        cluster_ = [];

        % The holder for the object performing job clean-up operations
        job_destroyer_ = [];

        % The auxiliary property, which tells if a cluster is starting for
        % the first time or is reused.
        job_is_starting_ = true;
    end

    methods
        function jd = JobDispatcher(varargin)
            % Initialize job dispatcher.
            % If provided with parameters, the first parameter should be
            % the sting-prefix of the job control files, used to distinguish
            % this job's control files from any other job control files
            %Example
            % jd = JobDispatcher() -- use randomly generated job control
            % prefix
            % jd = JobDispatcher('target_file_name') -- add prefix
            %      which distinguishes this job. The job which will produce
            %      a folder for message transfer with the name provided
            %
            % Initialize messages framework
            mf = MessagesFilebased(varargin{:});
            pc = parallel_config;
            if ~isempty(pc.shared_folder_on_local)
                mf.mess_exchange_folder = pc.shared_folder_on_local;
            end
            jd.mess_framework_ = mf;
        end

        function [outputs,n_failed,task_ids,this]=start_job(this,...
                job_class_name,common_params,loop_params,return_results,...
                number_of_workers,keep_workers_running,task_query_time)
            % Starts the cluster and sends parallel job to be executed by
            % Matlab cluster.
            %
            % Usage:
            % [n_failed,outputs,task_ids,this] = ...
            %     this.start_job(job_class_name,common_params,loop_params,...
            %    [number_of_workers,[job_query_time]])
            %
            %Where:
            % job_class_name -- name of the class - child of JobExecutor,
            %                   which will process task on a separate worker
            % common_params  -- a structure, containing the parameters, common
            %                   to every loop iteration
            % loop_params    -- either cell array of structures,
            %                   with each cell specific to a loop iteration
            %                   or the number of iterations to do over
            %                   common_params (which may depend on the
            %                   iteration number defined in JobExecutor)
            % return_results -- set to true if the job is expected to return
            %                   some results
            % number_of_workers -- number of Matlab sessions to
            %                    process the tasks
            %
            %
            % Optional:
            % keep_workers_running -- true if workers should not finish
            %                    after the task is completed and wait for
            %                    the task to be resubmitted. Necessary if
            %                    one needs to run another job to the
            %                    cluster.
            %
            % task_query_time -- if present -- time interval in seconds to
            %                    check if tasks are completed. By default,
            %                    check every 4 seconds
            %
            % Returns:
            % outputs   -- cell array of outputs from each task.
            %              Empty if tasks do not return anything
            % n_failed  -- number of tasks that has failed.
            % task_ids   -- cell array containing relation between task_id
            %              (task number) and task parameters from
            %               tasks_param_list, assigned to this task

            if ~exist('task_query_time', 'var')
                task_query_time = 4;
            end
            if ~exist('keep_workers_running', 'var')
                keep_workers_running = false;
            end
            [outputs,n_failed,task_ids,this]=send_tasks_to_workers_(this,...
                job_class_name,common_params,loop_params,return_results,...
                number_of_workers,keep_workers_running,task_query_time);
        end

        function [outputs,n_failed,task_ids,this]=restart_job(this,...
                job_class_name,common_params,loop_params,return_results,...
                keep_workers_running,task_query_time)
            % Restart parallel Matlab job started earlier by start_job command,
            % providing it with new data. The cluster to do the job must be running.
            %
            % Usage:
            % [n_failed,outputs,task_ids,this] = ...
            %     this.restart_job(this,job_class_name,common_params,loop_params,...
            %     [return_results,[keep_workers_running,[job_query_time]]])
            %
            %Where:
            % job_class_name -- name of the class - child of JobExecutor,
            %                   which will process task on a separate worker
            % common_params  -- a structure, containing the parameters, common
            %                   to every loop iteration
            % loop_params    -- either cell array of structures,
            %                   with each cell specific to a loop iteration
            %                   or the number of iterations to do over
            %                   common_params (which may depend on the
            %                   iteration number defined in JobExecutor)
            % return_results -- set to true if the job is expected to return
            %                   some results
            %
            % Optional:
            % keep_workers_running -- true if workers should not finish
            %                    after the task is completed and wait for
            %                    the task to be resubmitted. Necessary if
            %                    one needs to run another job to the
            %                    cluster.
            %
            % task_query_time -- if present -- time interval in seconds to
            %                    check if tasks are completed. By default,
            %                    check every 4 seconds
            %
            % Returns:
            % outputs   -- cell array of outputs from each task.
            %              Empty if tasks do not return anything
            % n_failed  -- number of tasks that has failed.
            % task_ids   -- cell array containing relation between task_id
            %              (task number) and task parameters from
            %               tasks_param_list, assigned to this task
            if ~exist('task_query_time', 'var')
                task_query_time = 4;
            end
            [outputs,n_failed,task_ids,this]=resend_tasks_to_workers_(this,...
                job_class_name,common_params,loop_params,return_results,...
                keep_workers_running,task_query_time);
        end

        %------------------------------------------------------------------

        function limit = get.fail_limit(this)
            limit  = this.fail_limit_;
        end

        function time = get.task_check_time(this)
            time = this.task_check_time_;
        end


        function this = set.task_check_time(this,val)
            if val<=0
                error('JOB_DISPATCHER:invalid_argument',...
                    'time to check jobs has to be positive');
            end
            this.task_check_time_ =val;
            this = reset_fail_limit_(this,this.time_to_fail/val);
        end

        function time = get.task_wait_time(this)
            time = this.task_wait_time_;
        end

        function this = set.task_wait_time(this,val)
            if val<=0
                error('JOB_DISPATCHER:invalid_argument',...
                    'time to wait jobs has to be positive');
            end
            this.task_wait_time_ =val;
        end

        function time = get.time_to_fail(this)
            time = this.time_to_fail_;
        end

        function this = set.time_to_fail(this,val)
            if val<0
                error('JOB_DISPATCHER:set_time_to_fail','time to fail can not be negative');
            end
            this.time_to_fail_ =val;
            this = reset_fail_limit_(this,val/this.task_check_time);
        end

        function mf = get.mess_framework(this)
            % return class used to communicate with the cluster
            mf = this.mess_framework_;
        end

        function id = get.job_id(this)
            % Return unique string describing the job
            id = this.mess_framework_.job_id;
        end

        function is = get.is_initialized(this)
            % Return true if job dispatcher is initialized,
            % i.e. this controls a parallel cluster

            is = ~isempty(this.cluster_);
        end

        function cl = get.cluster(this)
            % get access to the cluster used to run parallel job by this
            cl = this.cluster_;
        end

        function this = finalize_all(this)
            % Stop cluster and parallel processes and clear all messages.
            %
            % As this is not a handle class, invalid cluster
            % object may persist if delete is not reassigned a new object.
            %
            this.cluster_ = [];
            this.job_destroyer_ = [];
        end

        function display_fail_job_results(this,outputs,n_failed,n_workers,varargin)
            % Display job results if the job has failed.
            % Auxiliary method.
            %
            % Input:
            % outputs -- usually cell array of the results, returned by a
            %            parallel job
            % n_failed -- number of tasks failed as the result of parallel
            %             job
            % n_workers-- number of Matlab sessions used by parallel job initially
            %
            % if present:
            % err_code -- the text string in the form
            %             ERROR_CLASS:error_reason to form identifier of
            %             the exception to throw.
            %             If this parameter is missing, method throws nothing.
            % Throws:
            % First exception returned from the cluster if any exceptions
            % are present or exception with err_code as MException.identifier
            % if no errors returned
            %
            if nargin<5
                err_code = [];
            else
                err_code = varargin{1};
            end
            display_fail_jobs_(this,outputs,n_failed,n_workers,err_code);
        end

        function this = migrate_exchange_folder(this)
            % the function used to change location of message exchange
            % folder when task is completed and new task should start.
            %
            % used to bypass issues with NFS caching when changing subtasks
            %
            if isempty(this.mess_framework_)
                return;
            end
            this.mess_framework_.migrate_message_folder();

            if ~isempty(this.cluster_)
                this.cluster_ = this.cluster_.set_mess_exchange(this.mess_framework_);
            end
        end

    end
    methods(Static)
        function [task_id_list,init_mess]=split_tasks(common_par,loop_par,return_outputs,n_workers)
            % Divide list of job parameters among given number of workers
            % and generate list of init messages for the subtasks
            %
            %Inputs:
            % common_param  -- the structure, containing the parameters
            %                  common to all workers and all iterations
            %
            % loop_par      -- cell array of classes or structures, containing task parameters
            %                  or number of iterations in the parallel loop.
            %
            % return_outputs -- if true, job must return its outputs
            %
            % n_workers      -- number of workers to split job between
            %
            %Returns:
            % task_id_list  -- cell array of indices from job_param_list dedicated
            %                  to run on a worker. Cell array would contain
            %                  the list of indices from loop_par if loop_par
            %                  is a cell array or a cell array of pairs in the
            %                  form n_first:n_points if loop_par is a number
            % init_mess     -- cell array (size: n_workers) of messages containing
            %                  initialization information for workers
            [task_id_list,init_mess]=split_tasks_(common_par,loop_par,return_outputs,n_workers);
        end

    end
end
