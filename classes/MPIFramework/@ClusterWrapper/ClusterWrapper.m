classdef ClusterWrapper
    % The class-wrapper containing common code for any Matlab cluster,
    % and job progress logging operations supported by Herbert
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
    %
    %----------------------------------------------------------------------
    properties(Dependent)   %
        % the property identifies that wrapper received the message that
        % the cluster status have changed
        status_changed;
        % the current cluster status, usually defined by status message
        status;
        % short abbreviation of the status property.
        status_name;
        % The string which describes the current status
        log_value
        % The accessor for mess_exchange_framework.job_id if mess exchange
        % framework is defined
        job_id
        % number of workers (numLabs) in the cluster
        n_workers;
        % defines the behavior of each worker when the particular task is
        % finished.
        % for parpool worker this should be false as MPI framework
        % reports failure, while for Java worker this should be true, as
        % Matlab workers should finish when parallel job ends.
        exit_worker_when_job_ends;
        % Cluster configuration contains the information about the cluster
        % one needs to provide to run mpi job on the appropriate
        % MPI cluster.  If the mpi job is run on a single node, the cluster
        % configuration is not necessary so this field contains 'local'
        % info. If one wants to run e.g. mpi job using mpiexec, the cluster
        % configuration should refer to the appropriate hosts file
        cluster_config
    end
    properties(Access = protected)
        % the name of the function or function handle of the function
        % to run a remote job. The function must be
        % on the Matlab data search path before Horace is initialized.
        worker_name_ = 'worker_v1';
        % if the worker is compiled Matlab application or Matlab script
        is_compiled_script_ = false;
        %------------------------------------------------------------------
        
        % number of workers in the pool
        n_workers_   = 0;
        % the holder for class, responsible for the communications with pool
        mess_exchange_ =[];
        % The name of the class, responsible for message exchange
        % between the workers within the pool (cluster)
        mess_exchange_inpool_ = [];
        % property, indicating changes in the pool status
        status_changed_ = false;
        %  property, containing the message, describing the current status
        current_status_ = [];
        %  property, containing the message, describing the previous status
        prev_status_=[];
        % the holder for the string, which describes the current pool
        % status.
        log_value_ = '';
        %
        cluster_config_ = 'local'
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
        LOG_MESSAGE_LENGHT=40;
        % messages to display if corresponding cluster is starting.
        starting_info_message_ ='';
        started_info_message_ ='';
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
            if nargin < 2
                return;
            end
            if ~exist('log_level','var')
                log_level = -1;
            end
            obj = obj.init(n_workers,mess_exchange_framework,log_level);
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
            if ~exist('log_level','var')
                log_level = -1;
            end
            if log_level > -1
                fprintf(obj.starting_info_message_,n_workers);
            end
            
            obj.mess_exchange_ = mess_exchange_framework;
            obj.n_workers_   = n_workers;
            
            
            obj.LOG_MESSAGE_WRAP_LENGTH = ...
                numel(mess_exchange_framework.job_id)+numel('***Job :   state: ');
            obj.LOG_MESSAGE_LENGHT = numel('***Job :  : state:  started |')+...
                numel(mess_exchange_framework.job_id) -numel('****  ****');
        end
        %
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
            if ~exist('log_message_prefix','var')
                log_message_prefix = 'starting';
            end
            
            
            obj = start_workers_(obj,je_init_message,task_init_mess,log_message_prefix );
        end
        %
        function [completed, obj] = check_progress(obj,varargin)
            % Check the job progress verifying and receiving all messages,
            % sent from worker N1
            %
            % usage:
            %>> [completed, obj] = check_progress(obj)
            %>> [completed, obj] = check_progress(obj,status_message)
            %
            % The first form checks and receives all messages addressed to
            % job dispatched node where the second form accepts and
            % verifies status message, received by other means
            [completed,obj] = check_progress_(obj,varargin{:});
        end
        %
        function obj = display_progress(obj,varargin)
            % report job progress using internal state of the cluster
            % calculated by executing check_progress method
            %
            options = {'-force_display'};
            [ok,mess,force_display,argi] = parse_char_options(varargin,options);
            if ~ok;error('CLUSTER_WRAPPER:invalid_argument',mess); end
            
            obj = obj.generate_log(argi{:});
            if force_display
                display_log = true;
            else
                hc = herbert_config;
                log_level = hc.log_level;
                if log_level > 0
                    display_log = true;
                else
                    display_log = false;
                end
            end
            if display_log
                fprintf(obj.log_value);
            end
        end
        %
        function obj=finalize_all(obj)
            % Close parallel framework, delete filebased exchange folders
            % and complete parallel job
            if ~isempty(obj.mess_exchange_)
                obj.mess_exchange_.finalize_all();
                obj.mess_exchange_ = [];
            end
        end
        %
        function [outputs,n_failed,obj]=  retrieve_results(obj)
            % retrieve parallel job results
            [outputs,n_failed,obj] = get_job_results_(obj);
        end
        function check_availability(obj)
            % verify the availability of a particular type of framework
            % (cluster)
            %
            % Should throw PARALLEL_CONFIG:not_avalable exception
            % if the particular framework is not available.
            %
            % This function is empty as the generic cluster wrapper and
            % its full implementation ClusterHerbert are always available.
            % 
            % unavailable cluster throws PARALLEL_CONFIG:not_available
            % exception.
        end
        % The property returns the list of the configurations, avalible for
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
        %
        function isit = get.status(obj)
            isit = obj.current_status_;
        end
        function obj = set.status(obj,mess)
            obj = obj.set_cluster_status(mess);
        end
        %
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
        
    end
    
    methods(Access=protected)
        function obj = generate_log(obj,varargin)
            % prepare log message from input parameters and the data, retrieved
            % by check_progress method
            obj = generate_log_(obj,varargin{:});
        end
        function obj = set_cluster_config_(obj,val)
            if ~strcmpi(val,obj.cluster_config_)
                warning('CLUSTER_WRAPPER:invalid_argument',...
                    'This type of cluster wrapper accepts only %s configuration. Changed to %s',...
                    obj.cluster_config_,obj.cluster_config_)
            end
            
        end
        
        function obj = set_cluster_status(obj,mess)
            % protected set status function, necessary to be able to
            % overload set.status method.
            if isa(mess,'aMessage')
                stat_mess = mess;
            elseif ischar(mess)
                stat_mess = aMessage(mess);
            else
                error('CLUSTER_WRAPPER:invalid_argument',...
                    'status is defined by aMessage class only or a message name')
            end
            obj.prev_status_ = obj.current_status_;
            obj.current_status_ = stat_mess;
            if obj.prev_status_ ~= obj.current_status_
                obj.status_changed_ = true;
            end
            
        end
        function ex = exit_worker_when_job_ends_(obj)
            % function defines desired completeon of the workers.
            % exit true for java-controlled worker and false for parallel
            % computing toolbox controlled one.
            ex  = true;
        end
        
    end
end

