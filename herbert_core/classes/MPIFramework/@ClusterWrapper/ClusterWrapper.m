classdef ClusterWrapper
    % The class-wrapper containing common code for any Matlab cluster,
    % and job progress logging operations supported by Herbert
    %
    %----------------------------------------------------------------------
    properties
        % The time to wait for cluster to start (in sec). If this time is
        % exceeded,
        % the cluster reports failure and parallel job will not start.
        cluster_startup_time = 120 % 2min
        % If true, write logs containing information about each parallel
        % executor (sets DO_LOGGING=true) in parallel worker
        DEBUG_REMOTE = false;
    end

    properties(Dependent)
        % The string, providing unique identifier(name) for the job and cluster.
        % accessor for mess_exchange_framework.job_id if mess exchange
        % framework is defined
        job_id
        % number of workers (numLabs) in the cluster
        n_workers;
        % Cluster configuration contains the information about the cluster
        % one needs to provide to run mpi job on the appropriate
        % MPI cluster.  If the mpi job is run on a single node, the cluster
        % configuration is not necessary so this field contains 'local'
        % info. If one wants to run e.g. mpi job using mpiexec, the cluster
        % configuration should refer to the appropriate hosts file
        cluster_config

        % the current cluster status, usually defined by status message,
        % e.g. The string which describes the current status
        status;
        % short abbreviation of the status property.
        status_name;
        % the property identifies that wrapper received the message that
        % the cluster status have changed.
        status_changed;
        % the string to display to user the current state of the cluster
        log_value
        % defines the behavior of each worker when the particular task is
        % finished.
        % for parpool worker this should be false as MPI framework
        % reports failure, while for Java worker this should be true, as
        % Matlab workers should finish when parallel job ends.
        exit_worker_when_job_ends;
        % The name of the framework, used for message exchange within the
        % cluster. Property used in debugging to change default framework
        pool_exchange_frmwk_name
    end

    properties(Access = protected)
        % The default name of the function or function handle of the function
        % to run a remote job. The function itself must be
        % on the Matlab data search path before Horace is initialized.
        % Can be redefined in parallel_config.
        worker_name_ = 'worker_v2';
        % if the worker is compiled Matlab application or Matlab script
        is_compiled_script_ = false;
        %------------------------------------------------------------------

        % number of workers in the pool
        n_workers_   = 0;
        % the holder for class, responsible for the communications between
        % the pool and control node
        mess_exchange_ =[];
        % The name of the class, responsible for message exchange
        % between the workers within the pool (cluster)
        pool_exchange_frmwk_name_ = '';

        % the holder for the string, which describes the current pool
        % status.
        log_value_ = '';
        % Definition for various cluster configuration. Will be overridden
        % by children as different type of children have different types of
        % configuration.
        cluster_config_ = 'local'
        %------------------------------------------------------------------
        % the string, describing the operations to launch Matlab or
        % compiled Matlab job
        matlab_starter_  = [];
        % The name of the cluster to print in logs to inform about parallel
        % program execution
        starting_cluster_name_;
        % the map containing the enviroment variables, common for all
        % clusters
        common_env_var_= containers.Map(...
            {'MATLABPATH',...  Additional Matlab m-files search path, containing horace_on/herbert_on initialization scripts and Matlab worker script ($PARALLEL_WORKER value), run by Matlab when it runs in the script mode
            'HERBERT_PARALLEL_EXECUTOR',... the program which executes the parallel job on server. Matlab or compiled Horace
            'HERBERT_PARALLEL_WORKER',... the parameters string used as input arguments for the parallel job. If its Matlab, it is the worker name and the run parameters.
            'WORKER_CONTROL_STRING',...  input for the script, containing encoded info about the location of the exchange folder
            'DO_PARALLEL_MATLAB_LOGGING',...  if 'true' each parallel process will write progress log
            }, {'','matlab','worker_v2','','false'});
        %------------------------------------------------------------------
        % properties, indicating changes in the pool status and used by
        % display_progress to build nuce progress logs
        current_status_ = [];  %  message, describing the current status
        status_changed_ = false; % if the current_status_ differs from prev_status_
        % messages to display if corresponding cluster is starting.
        starting_info_message_ ='';
        started_info_message_ ='';
    end

    properties(Access=private)
        %------------------------------------------------------------------
        % Auxiliary properties, defining the output of the log messages
        % about the cluster status.
        %
        % counter of the attempts to receive status message from cluster which
        % were unsuccessful
        display_results_count_ = 0;
        % the length of the log message envelope (redefined in constructor)
        LOG_MESSAGE_WRAP_LENGTH =10;
        % total length of the string with log message to display (redefined in constructor)
        LOG_MESSAGE_LENGTH=40;

        %
        % running process Java exception message contents, used to identify
        % if java process report it has been completed
        running_mess_contents_= 'process has not exited';
    end

    properties(Hidden,Dependent)
        % helper property to print nicely aligned log messages
        log_wrap_length;
    end

    methods
        function obj = ClusterWrapper(n_workers,mess_exchange_framework,log_level)
            % Constructor, which initiates Parallel clusters wrapper, to
            % control Matlab parallel toolbox framework using common
            % interface.
            %
            % Empty constructor generates wrapper which has to be
            % initiated by init method.
            %
            % Non-empty calls the init method itself
            %
            % Inputs (if any):
            % n_workers -- number of independent Matlab workers to execute
            %              a job
            % mess_exchange_framework -- a class-child of
            %              iMessagesFramework, used  for communications
            %              between cluster and the host Matlab session,
            %              which started and controls the job.
            % log_level    if present, defines the verbosity of the
            %              operations over the framework

            obj.running_mess_contents_= 'process not exited';

            if nargin < 2
                return;
            end
            if ~exist('log_level', 'var')
                log_level = -1;
            end

            obj = obj.init(n_workers,mess_exchange_framework,log_level);
        end

        function obj = set_mess_exchange(obj,mess_exchange)
            if ~isa(mess_exchange,'iMessagesFramework')
                error('CLUSTER_WRAPPER:invalid_argument',...
                    ' can set only instance of message exchange framework but setting %s',...
                    evalc('disp(mess_exchange)'));
            end
            obj.mess_exchange_ = mess_exchange;
        end

        function obj = init(obj,n_workers,mess_exchange_framework,log_level)
        % The method to initiate the cluster wrapper
        %
        % Inputs:
        % n_workers -- number of independent Matlab workers to execute
        %              a job
        % mess_exchange_framework -- a class-child of
        %              iMessagesFramework, used  for communications
        %              between cluster and the host Matlab session,
        %              which started and controls the job.
        %log_level     if present, the number, which describe the
        %              verbosity of the cluster operations output;

            if ~exist('log_level', 'var')
                log_level = -1;
            end

            if log_level > -1
                fprintf(2,'******************************************************\n');
                fprintf(2,obj.starting_info_message_,n_workers);
            end
            obj = obj.set_mess_exchange(mess_exchange_framework);

            obj.n_workers_   = n_workers;


            obj.LOG_MESSAGE_WRAP_LENGTH = ...
                numel(mess_exchange_framework.job_id)+numel('***Job :   state: ');
            obj.LOG_MESSAGE_LENGTH = numel('***Job :  : state:  started |')+...
                numel(mess_exchange_framework.job_id) -numel('****  ****');

            % get worker defined in parallel config
            pc = parallel_config();
            obj.worker_name_ = pc.worker;
            obj.is_compiled_script_ = pc.is_compiled;

            % define Matlab:
            prog_path  = find_matlab_path();
            if isempty(prog_path)
                error('HERBERT:ClusterWrapper:runtime_error',...
                    'Can not find Matlab');
            end

            if ispc()
                obj.matlab_starter_ = fullfile(prog_path,'matlab.exe');
            else
                obj.matlab_starter_= fullfile(prog_path,'matlab');
            end

            if obj.is_compiled_script_
                obj.common_env_var_('HERBERT_PARALLEL_EXECUTOR') = obj.worker_name_;
            else
                obj.common_env_var_('HERBERT_PARALLEL_EXECUTOR') = obj.matlab_starter_;
            end

            % additional Matlab m-files search path to be available to
            % workers
            existing_addpath = getenv('MATLABPATH');
            possible_addpath = fileparts(which(pc.worker));

            if  contains(existing_addpath,possible_addpath)
                obj.common_env_var_('MATLABPATH') = existing_addpath;
            else
                if isempty(existing_addpath)
                    obj.common_env_var_('MATLABPATH') = possible_addpath;
                else
                    obj.common_env_var_('MATLABPATH') = ...
                        [possible_addpath,pathsep,existing_addpath];
                end
            end

            if obj.DEBUG_REMOTE
                obj.common_env_var_('DO_PARALLEL_MATLAB_LOGGING') = 'true';
            else
                obj.common_env_var_('DO_PARALLEL_MATLAB_LOGGING') = 'false';
            end

        end

        function obj = start_job(obj,je_init_message,task_init_mess,log_message_prefix)
            % send initialization information to each worker in the cluster
            % providing information about the particular parallel job.
            %Inputs:
            % je_init_message -- The message prepared by messages framework
            %                    and containing information about the
            %                    particular job_executor the worker would run
            %                    and the way this job_executor would be
            %                    treated by the worker. The message is the
            %                    same for every worker
            % task_init_mess  -- The list of messages, generated by
            %                    JobDispatcher split_tasks method and
            %                    containing the initialization messages for
            %                    every instance of jobExecutor on every
            %                    worker. Usually different for each worker,
            %
            % log_message_prefix - the prefix of the log message,
            %                     displayed when a parallel job is started,
            %                     indicating previous state of the cluster
            %                     running this job e.g. 'starting' or
            %                     'continuing'
            %
            %
            obj = obj.init_workers(je_init_message,task_init_mess,log_message_prefix);
        end

        function obj = init_workers(obj,je_init_message,task_init_mess,log_message_prefix)
            % send initialization information to each worker in the cluster
            % providing information about parallel job.
            %Inputs:
            % je_init_message -- The message prepared by messages framework
            %                    and containing information about the
            %                    particular job_executor the worker would run
            %                    and the way this job_executor would be
            %                    treated by the worker. The message is the
            %                    same for every worker
            % task_init_mess  -- The list of messages, generated by
            %                    JobDispatcher split_tasks method and
            %                    containing the initialization messages for
            %                    every instance of jobExecutor on every
            %                    worker. Usually different for each
            %
            % log_message_prefix - the prefix of the log message,
            %                     displayed when a parallel job is started,
            %                     indicating previous state of the cluster
            %                     running this job e.g. 'starting' or
            %                     'continuing'
            %
            if ~exist('log_message_prefix', 'var')
                log_message_prefix = 'starting';
            end

            obj = init_workers_(obj,je_init_message,task_init_mess,log_message_prefix );
        end

        function [obj, task_id] = start_workers(obj, worker_control_string, ...
                                                varargin)
        % Start workers running in parallel and return appropriate task_id to calling function
        % Should appropriately start workers for the Herbert, mpiexec_mpi and slurm_mpi modes
        %
        % Inputs:
        %  prefix_command  -- Commands placed before the main matlab call
        %  postfix_command -- Extra arguments and flags passed to the main matlab call
        %  matlab_extra    -- Commands to be run before starting parallel worker
        %  debug           -- Direct stdout of workers to host stdout
        %  target_threads  -- Start matlab jobs running with this many threads
            par = parallel_config;
            p = inputParser();
            addOptional(p, 'prefix_command' , {}, @iscellstr);
            addOptional(p, 'postfix_command', {}, @iscellstr);
            addOptional(p, 'matlab_extra'   , '', @isstring);
            addOptional(p, 'debug', par.debug, @islognumscalar);
            addOptional(p, 'target_threads', par.par_threads, @isnumeric);
            parse(p, varargin{:});

            prefix_command = p.Results.prefix_command;
            postfix_command = p.Results.postfix_command;
            matlab_extra = p.Results.matlab_extra;

            obj.common_env_var_('WORKER_CONTROL_STRING') = worker_control_string;

            task_info = obj.generate_run_string(target_threads, ...
                prefix_command, postfix_command, matlab_extra);

            if ispc()
                runtime = java.lang.ProcessBuilder('cmd.exe');
            else
                runtime = java.lang.ProcessBuilder('/bin/sh');
            end

            if p.Results.debug
                runtime.inheritIO();
            end

            env = runtime.environment();
            obj.set_env(env);

            runtime = runtime.command(task_info);
            task_id = runtime.start();

        end

        function task_info = generate_run_string(obj, target_threads, ...
                                                 prefix_command, postfix_command, matlab_extra)
            % Construct the string required for running a parallel Horace instance based on the required
            % threads, and any extra commands which need to be added (e.g. mpi starters)

            matlab_command = sprintf('maxNumCompThreads(%d);%s;%s(''%s'');exit;', ...
                target_threads, ...
                matlab_extra, ...
                obj.worker_name_, ...
                obj.common_env_var_('WORKER_CONTROL_STRING'));

            task_info = [prefix_command(:)',...
                {obj.common_env_var_('HERBERT_PARALLEL_EXECUTOR')},...
                postfix_command(:)', ...
                {'-batch'},{matlab_command}];
        end


        function [obj,ok]=wait_started_and_report(obj,check_time,varargin)
            % check for 'ready' message and report cluster ready to user.
            %
            % if not ready for some reason, report the failure and
            % diagnostics.
            % Returns:
            % initialized cluster object with appropriate status set.
            % ok -- true if cluster started successfully and false if it
            % does not
            %
            if ~exist('check_time', 'var')
                check_time = 4;
            end
            [obj,ok] = wait_started_and_report_(obj,check_time,varargin{:});
        end

        function [completed, obj] = check_progress(obj,varargin)
            % Check the job progress from MPI job control system and
            % verifying and receiving all messages,
            % sent from Worker 1 in normal circumstances and all
            % other workers in case of failure.
            %
            % usage:
            %>> [completed, obj] = check_progress(obj) -- check and receive
            %                      information from appropriate parallel job
            %                      control system and receive all messages
            %                      control/log messages addressed to
            %                      the headnode to identify the
            %
            %>> [completed, obj] = check_progress(obj,status_message) accept
            %                      and verify status message, provided as
            %                      input
            if isempty(varargin)
                if obj.is_job_initiated()
                    [running,failedC,paused,messC]=get_state_from_job_control(obj);
                else
                    paused  = false;
                    running = false;
                    failedC = true;
                    messC   = FailedMessage('Job Initialization process have failed or has not been started');
                end
            else
                paused = false;
                running =true;
                failedC = false;
                messC = varargin{1};
                if ~isempty(messC) && isa(messC,'FailedMessage')
                    failedC = true;
                end
            end

            if paused
                completed = false;
                failed    = false;
                mess = 'paused';
            else
                [completed,failed,mess] = check_progress_from_messages_(obj,varargin{:});
            end

            if isempty(mess) % the information is from job control
                obj.status = messC;
            else % messages should contain better information about the issue
                obj.status = mess;
            end

            if ~running && ~completed
                % has Matlab MPI job been completed before status message has
                % been delivered?
                mess = obj.mess_exchange_.probe_all(1,'completed');
                if isempty(mess)
                    if ~(failedC && ~isempty(messC))
                        fm = FailedMessage(...
                            'Cluster reports job completed but the final completeon messages has not been received');

                        obj.status  = fm;
                    end
                    failed = true;
                end
            end

            if ~completed && (failed || failedC)
                % failure. The reason should be in mess.
                completed = true;
            end
        end

        function obj = display_progress(obj,varargin)
            % report job progress using internal state of the cluster
            % calculated by executing check_progress method
            %
            options = {'-force_display'};
            [ok,mess,force_display,argi] = parse_char_options(varargin,options);

            if ~ok
                error('CLUSTER_WRAPPER:invalid_argument',mess);
            end

            obj = obj.generate_log(argi{:});
            if force_display
                display_log = true;
            else
                hc = herbert_config;
                log_level = hc.log_level;

                display_log = log_level > 0;
            end

            if display_log
                highlight_failure = contains(obj.log_value,'failed');

                if numel(obj.log_value) > 4*obj.LOG_MESSAGE_LENGTH
                    if highlight_failure
                        newStr = splitlines(obj.log_value);
                        fprintf(2,'%s\n',newStr{1});
                    end
                    disp(obj.log_value)
                    if highlight_failure
                        fprintf(2,'***************************************************\n');
                    end
                else
                    if highlight_failure
                        fprintf(2,obj.log_value);
                    else
                        fprintf(obj.log_value);
                    end
                end
            end
        end

        function obj=finalize_all(obj)
            % Close parallel framework, delete filebased exchange folders
            % and complete parallel job
            if ~isempty(obj.mess_exchange_)
                obj.mess_exchange_.finalize_all();
                new_mess_exchange_folder = obj.mess_exchange_.next_message_folder_name;
                if is_folder(new_mess_exchange_folder)
                    [ok,mess]=rmdir(new_mess_exchange_folder,'s');
                    if ~ok
                        warning(' can not clean-up prospective message exchange folder %s Reason %s',...
                            new_mess_exchange_folder,mess);
                    end
                end
                obj.mess_exchange_ = [];
            end
            % clear enviromental variables set earlier to avoid
            % possible interference
            vars = obj.common_env_var_.keys;
            cellfun(@(var)setenv(var,''),vars);
        end

        function [outputs,n_failed,obj]=  retrieve_results(obj)
            % retrieve parallel job results
            [outputs,n_failed,obj] = get_job_results_(obj);
        end

        function check_availability(~)
            % verify the availability of a particular type of framework
            % (cluster)
            %
            % Should throw PARALLEL_CONFIG:not_avalable exception
            % if the particular framework is not available.
            worker = config_store.instance.get_value('parallel_config','worker');
            assert(~isempty(which(worker)) || exist(worker, 'file'), ...
                'HERBERT:ClusterWrapper:not_available',...
                'Parallel worker %s is not on Matlab path. Parallel extensions are not available',...
                worker);
        end

        % The property returns the list of the configurations, available for
        % usage by the
        function config = get_cluster_configs_available(obj)
            % The function returns the list of the available clusters
            % to run using correspondent parallel framework.
            %
            % The first configuration in the clusters list would be the
            % default configuration.
            config = {obj.cluster_config_};
        end

        %------------------------------------------------------------------
        % SETTERS, GETTERS:
        %------------------------------------------------------------------
        function isit = get.status_changed(obj)
            isit = obj.status_changed_;
        end

        function name = get.status_name(obj)
            if isempty(obj.current_status_)
                name = 'undefined';
            else
                name = obj.current_status_.mess_name;
            end
        end

        function log = get.log_value(obj)
            log = obj.log_value_;
        end

        function id = get.job_id(obj)
            if isempty(obj.mess_exchange_)
                id = 'undefined';
            else
                id = obj.mess_exchange_.job_id();
            end
        end

        function nw = get.n_workers(obj)
            nw = obj.n_workers_;
        end

        function isit = get.status(obj)
            isit = obj.current_status_;
        end

        function obj = set.status(obj,mess)
            obj = obj.set_cluster_status(mess);
        end

        function len = get.log_wrap_length(obj)
            len = obj.LOG_MESSAGE_WRAP_LENGTH;
        end

        function ex = get.exit_worker_when_job_ends(obj)
            ex = exit_worker_when_job_ends_(obj);
        end

        function conf = get.cluster_config(obj)
            conf = obj.cluster_config_;
        end

        function obj = set.cluster_config(obj,val)
            % sets up configuration class, suitable for appropriate MPI
            % cluster.
            % overload set_cluster_config_ to check and accept such
            % configuration, used by the particular cluster.

            % only 'local' (or missing) configuration is used by default.
            obj = set_cluster_config_(obj,val);
        end

        function name = get.pool_exchange_frmwk_name(obj)
            name = obj.pool_exchange_frmwk_name_;
        end

        function frmwk = get_exchange_framework(obj)
            % get framework used for data exchange between running cluster
            % and control node.
            frmwk = obj.mess_exchange_;
        end

        function [completed,failed,mess] = check_progress_from_messages(obj,varargin)
            % function analystes received progress messages and calculates
            % progress from them
            %
            % Part of check_progress method. Exposed for testing purposes
            [completed,failed,mess] = check_progress_from_messages_(obj,varargin{:});
        end
    end

    methods(Access=protected)
        function env = set_env(obj,env)
            % helper function to set enviroment for a java process.
            % Inputs:
            % [env] -- If present, Matlab representation of the java env
            %          the enviroment will be set to java process space.
            %          If absent, the eniromental variables will be set up
            %          to current running Matlab version
            %
            keys = obj.common_env_var_.keys;
            val  = obj.common_env_var_.values;
            if exist('env','var')
                cellfun(@(name,val)env.put(name,val),keys,val,...
                    'UniformOutput',false);
            else
                cellfun(@(name,val)setenv(name,val),keys,val,...
                    'UniformOutput',false);
            end
        end

        function check_failed(obj)
            % run cluster-specific get_state_from_job_control function and
            % throw if this function return failure
            %
            % Used by init method, to identify cluster startup failure early.
            [~,failed,~,mess] = obj.get_state_from_job_control();
            if failed
                if isa(mess,'FailedMessage')
                    exc = mess.exception;
                    % generate exception report only if the exception
                    % contains useful information about the issue.
                    if ~isempty(exc) && ~strcmp(exc.identifier,'HERBERT:FailedMessage:no_aruments')
                        disp(exc.getReport())
                    end
                    info = '';
                    format = '%s cluster for job: %s failed to start parallel execution. State: %s %s';
                else
                    format = '%s cluster for job: %s failed to start parallel execution. State: %s Message: %s';
                    info = mess;
                end
                jobid = obj.job_id;
                stat_name  = obj.status_name;
                obj = obj.finalize_all();

                error('HERBERT:ClusterWrapper:runtime_error',format,...
                    obj.starting_cluster_name_,jobid,stat_name,info);

            end
        end

        function obj = generate_log(obj,varargin)
            % prepare log message from input parameters and the data, retrieved
            % by check_progress method
            obj = generate_log_(obj,varargin{:});
        end

        function obj = set_cluster_config_(obj,val)
            if ~strcmpi(val,obj.cluster_config_)
                warning('HERBERT:ClusterWrapper:invalid_argument',...
                    'This type of cluster wrapper accepts only %s configuration. Changed to %s',...
                    obj.cluster_config_,obj.cluster_config_)
            end

        end

        function obj = set_cluster_status(obj,mess)
            % Setter for status property
            % defined as function and protected to be able to
            % overload set.status method.
            %
            % Does substiturions for messages
            % running -> log
            % finished-> completed
            %
            obj = set_cluster_status_(obj,mess);
        end

        function ex = exit_worker_when_job_ends_(~)
            % function defines desired completion of the workers.
            % should be true for java-controlled worker and false for parallel
            % computing toolbox controlled one.
            ex  = true;
        end

        function [running,failed,mess] = is_java_process_running(obj,task_handle)
            % check if java process is still running or has been completed
            %
            % inputs:
            % task_handle -- handle for Java process
            % obj.running_mess_contents_ -- the string, containing the
            %                               part of the java message,
            %                               indicating that the process is
            %                               still running
            if isempty(task_handle)
                running = false;
                failed  = true;
                mess = 'process has not been started';
                return;
            end

            % Should redirect process error but does not. Why?
            %err_stream_scan = java.util.Scanner(task_handle.getErrorStream());
            %err_stream_scan.useDelimiter("\r\n");
            %if err_stream_scan.hasNext
            %    ok      = false;
            %    failed  = true;
            %    err_text = cell(1,1);
            %    err_text{end}='Java error output reported\n';
            %    while(err_stream_scan.hasNext)
            %        err_text{end+1} = err_stream_scan.next();
            %    end
            %    mess = strjoin(err_text,' ');
            %    return;
            %else
            mess = 'running';
            %end
            %err_stream_scan.close();

            is_alive = task_handle.isAlive();
            if is_alive
                running = true;
                failed  = false;
                return;
            end

            try
                term = task_handle.exitValue();
                if term == 0
                    if is_alive % thread is still running despite task have been completed
                        running = true;
                        failed  = false;
                        return;
                    else
                        failed = false;
                        running = false;
                        mess = 'Java process sucsessfulluy completed';
                    end
                else
                    failed = true;
                    mess = sprintf('Java process abnormal termination. Error ID: %d\n',term);
                    running = false;
                end
            catch Err
                if strcmp(Err.identifier,'MATLAB:Java:GenericException')
                    part = strfind(Err.message, obj.running_mess_contents_);
                    if isempty(part)
                        mess = Err.message;
                        failed = true;
                        running   = false;
                    else
                        running = true;
                        failed = false;
                    end
                else
                    rethrow(Err);
                end
            end
        end
    end

    methods(Static)
        function mpi_exec = get_mpiexec()
        % Get the appropriate mpiexec program for running MPI jobs
            mpi_exec  = config_store.instance().get_value('parallel_config','external_mpiexec');
            if ~isempty(mpi_exec)
                if is_file(mpi_exec) % found external mpiexec
                    return
                else
                    warning('HERBERT:ClusterMPI:invalid_argument',...
                        'External mpiexec %s selected but is not available',mpi_exec);
                end
            end

            % Get current horace root dir
            pths = horace_paths;
            external_dll_dir = fullfile(pths.horace, 'DLL', 'external');

            if ispc()
                mpi_exec = fullfile(external_dll_dir, 'mpiexec.exe');
            else
                mpi_exec = fullfile(external_dll_dir, 'mpiexec');
            end
        end
    end

    methods(Abstract,Access=protected)
        % get the state of running job by requesting reply from the job
        % control mechanism.
        [ok,failed,paused,mess] = get_state_from_job_control(~)
    end

    methods(Abstract)
        % returns true, if the cluster wrapper is running a cluster job
        ok = is_job_initiated(obj)
    end

end
