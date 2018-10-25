classdef JobDispatcher
    % The class to run and control Herbert MPI jobs.
    %
    % Allow user to run multi-session or MPI jobs, defined by the classes-children of
    % JobExecutor class.
    %
    % In case of Parallel computer toolbox available, runs Matlab MPI communicating jobs
    % and if it is not, uses multiple Matlab, communicating through filebased messages.
    %
    %
    % $Revision$ ($Date$)
    %
    %
    properties(Dependent)
        % how often (in second) job dispatcher should query the task status
        task_check_time;
        % fail limit -- number of times to try action until deciding the
        fail_limit     % action have failed
        % time interval to wait until job which do not send any messages
        % considered failed
        time_to_fail
        % -----------------------------------------------------------------
        % The convenience interface to internal classes, used by
        % JobDispatcher
        % Returns the string with running job id
        job_id
        % the framework used to exchange messages with parallel cluster
        mess_framework;
        % exposing read access to parallel cluster to run a parallel job
        cluster
        % true if jobDispatcher already controls a
        % cluster so the next job can be executed on existing cluster
        % rather then after starting a new one.
        is_initialized
    end
    %
    properties(Access=protected)
        task_check_time_ = 4;
        fail_limit_ = 100; % number of times to try for changes in job status file until
        % decided the job have failed
        %
        % The framework to exchange messages with the tasks
        mess_framework_;
        time_to_fail_  = 300; %300sec, 5 min
        
        % holder for initiated cluster allowing to resubmit jobs
        cluster_ = [];
        % the holder for the object performing job clean-up operations
        job_destroyer_ = [];
        % The auxiliary property, which tells if a cluster is started for
        % the first time or is reused.
        job_is_starting_ = true;
    end
    
    methods
        function jd = JobDispatcher(varargin)
            % Initialize job dispatcher
            % If provided with parameters, the first parameter should be
            % the sting-prefix of the job control files, used to distinguish
            % this job control files from any other job control files
            %Example
            % jd = JobDispatcher() -- use randomly generated job control
            % prefix
            % jd = JobDispatcher('target_file_name') -- add prefix
            %      which distinguish this job as the job which will produce
            %      the file with the name provided
            %
            % Initialise messages framework
            mess_cache.instance('delete');
            mf = MessagesFilebased(varargin{:});
            pc = parallel_config;
            if ~isempty(pc.shared_folder_on_local)
                mf.mess_exchange_folder = pc.shared_folder_on_local;
            end
            jd.mess_framework_  = mf;
        end
        %
        function [outputs,n_failed,task_ids,this]=start_job(this,...
                job_class_name,common_params,loop_params,return_results,...
                number_of_workers,keep_workers_running,task_query_time)
            % send parallel job to be executed by Matlab cluster
            %
            % Usage:
            % [n_failed,outputs,task_ids,this] = ...
            %     this.start_job(job_class_name,common_params,loop_params,...
            %    [number_of_workers,[job_query_time]])
            %
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
            %
            % Optional:
            % keep_workers_running -- true if workers should not finish
            %                    after the task is completed and wait for
            %                    the task to be resubmitted.
            %
            % task_query_time -- if present -- time interval in seconds to
            %                    check if tasks are completed. By default,
            %                    check every 4 seconds
            %
            % Returns
            % n_failed  -- number of tasks that have failed.
            % outputs   -- cellarray of outputs from each task.
            %              Empty if tasks do not return anything
            % task_ids   -- cellarray containing relation between task_id
            %              (task number) and task parameters from
            %               tasks_param_list, assigned to this task
            %
            if ~exist('task_query_time','var')
                task_query_time = 4;
            end
            if ~exist('keep_workers_running','var')
                keep_workers_running = false;
            end
            [outputs,n_failed,task_ids,this]=send_tasks_to_workers_(this,...
                job_class_name,common_params,loop_params,return_results,...
                number_of_workers,keep_workers_running,task_query_time);
        end
        %
        function [outputs,n_failed,task_ids,this]=restart_job(this,...
                job_class_name,common_params,loop_params,return_results,...
                keep_workers_running,task_query_time)
            % restart parallel Matlab job started earlier by start_job command,
            % providing it with new data. The cluster must be running
            %
            % Usage:
            % [n_failed,outputs,task_ids,this] = ...
            %     this.restart_job(this,job_class_name,common_params,loop_params,...
            %    ,[job_query_time]])
            %
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
            %
            % Optional:
            % keep_workers_running -- true if workers should not finish
            %                    after the task is completed and wait for
            %                    the task to be resubmitted.
            %
            % task_query_time -- if present -- time interval in seconds to
            %                    check if tasks are completed. By default,
            %                    check every 4 seconds
            %
            % Returns
            % n_failed  -- number of tasks that have failed.
            % outputs   -- cellarray of outputs from each task.
            %              Empty if tasks do not return anything
            % task_ids   -- cellarray containing relation between task_id
            %              (task number) and task parameters from
            %               tasks_param_list, assigned to this task
            %
            if ~exist('task_query_time','var')
                task_query_time = 4;
            end
            [outputs,n_failed,task_ids,this]=resend_tasks_to_workers_(this,...
                job_class_name,common_params,loop_params,return_results,...
                keep_workers_running,task_query_time);
        end
        
        %
        %------------------------------------------------------------------
        function limit = get.fail_limit(this)
            limit  = this.fail_limit_;
        end
        %
        function time = get.task_check_time(this)
            time = this.task_check_time_;
        end
        %
        function this = set.task_check_time(this,val)
            if val<=0
                error('JOB_DISPATCHER:invalid_argument',...
                    'time to check jobs has to be positive');
            end
            this.task_check_time_ =val;
            this = reset_fail_limit_(this,this.time_to_fail/val);
            
        end
        %
        function time = get.time_to_fail(this)
            time = this.time_to_fail_;
        end
        %
        function this = set.time_to_fail(this,val)
            if val<0
                error('JOB_DISPATCHER:set_time_to_fail','time to fail can not be negative');
            end
            this.time_to_fail_ =val;
            this = reset_fail_limit_(this,val/this.task_check_time);
        end
        
        function mf = get.mess_framework(obj)
            % return class, used to communicate with the cluster
            mf = obj.mess_framework_;
        end
        function id = get.job_id(obj)
            % return unique string, describing the job
            id = obj.mess_framework_.job_id;
        end
        function is = get.is_initialized(obj)
            % return true if job dispatcher is initialized i.e. holds
            % control over a parallel cluster
            is = ~isempty(obj.cluster_);
        end
        function cl = get.cluster(obj)
            % get access to the cluster, used to run parallel job by this
            % class
            cl = obj.cluster_;
        end
        %
        function obj = finalize_all(obj)
            % destructor. As this is not a handle class, invalid cluster_
            % object may stay if delete does not assigned to a new object
            mess_cache.instance('delete');
            obj.cluster_ = [];
            obj.job_destroyer_ = [];
        end
        function display_fail_job_results(obj,outputs,n_failed,n_workers,Err_code)
            % Auxiliary method to display job results if the job have
            % failed
            % Input:
            % Outputs -- usually cellarray of the results, returned by a
            %            parallel job
            % n_failed -- number of tasks failed as the result of parallel
            %             job
            % n_workers-- number of labs used by parallel job initially
            %
            % Err_code -- the text string in the form
            %             ERROR_CLASS:error_reason to form identifier of
            %             the exception to throw
            % Throws:
            % First exception returned from the cluster if such exceptions
            % are present or exception with Err_code as MExeption.identifier
            % if no errors returned
            %
            mEXceptions_outputs = false(size(outputs));
            if iscell(outputs)
                fprintf('Job %s have failed. Outputs: \n',obj.job_id);
                for i=1:numel(outputs)
                    if isa(outputs{i},'MException')
                        mEXceptions_outputs(i) = true;
                        fprintf('Task N%d failed. Error %s; Message %s\n',...
                            i,outputs{i}.identifier,outputs{i}.message);
                    else
                        mEXceptions_outputs(i) = false;
                        fprintf('Task N%d failed. Outputs: \n',i);
                        if isempty(outputs{i})
                            fprintf('[]\n');
                        else
                            disp(outputs{i});
                        end
                    end
                end
            else
                mEXceptions_outputs(1) = isa(outputs,'MException');
                fprintf('Job %s have failed. Output: \n',obj.job_id);
                disp(outputs);
            end
            if any(mEXceptions_outputs)
                warning(Err_code,...
                    ' Number: %d parallel tasks out of total: %d tasks have failed',...
                    n_failed,n_workers)
                errOutputs = outputs(mEXceptions_outputs);
                if iscell(errOutputs)
                    for i=1:numel(errOutputs)
                        disp(['***** Error output N ',num2str(i)]);
                        disp(getReport(errOutputs{i}))
                    end
                else
                    disp(getReport(errOutputs))
                end
                error(Err_code,'Parallel job have failed, producing errors above.');                
            else
                error(Err_code,...
                    ' Number: %d parallel tasks out of total: %d tasks have failed',...
                    n_failed,n_workers)
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
            %                  common for all workers and all iterations
            %
            % loop_par      -- cellarray of classes or structures, containing task parameters
            %                  or number of iterations in the parallel
            %                  loop.
            %
            % return_outputs -- if true, job must return its outputs
            %
            % n_workers      -- number of workers to split job between workers
            %
            %Returns:
            % task_id_list  -- cell array of indexes from job_param_list dedicated
            %                  to run on a worker. Cellarray would contain
            %                  the list of indexes from loop_par if loop_par
            %                  is a cellarray or cellarray of pairs in the
            %                  form n_first:n_points if loop_par is the number
            % init_mess     -- size n_workers cellarray of messages containing
            %                  initialization information for workers
            [task_id_list,init_mess]=split_tasks_(common_par,loop_par,return_outputs,n_workers);
        end
        
    end
end

