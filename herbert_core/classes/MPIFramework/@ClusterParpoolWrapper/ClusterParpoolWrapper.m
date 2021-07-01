classdef ClusterParpoolWrapper < ClusterWrapper
    % The class-wrapper for parallel computing toolbox cluster and MPI
    % job submission/execution routines providing the same interface as Herbert
    % custom parallel classes.
    %
    %----------------------------------------------------------------------
    properties(Access = protected)
        cluster_ =[];
        current_job_ = [];
        task_ = [];
        
        cluster_prev_state_ =[];
        cluster_cur_state_ = [];
    end
    properties(Constant,Access = private)
        % list of states available for parallel computer toolbox cluster
        % class
        par_cluster_state_names_ = {'pending','paused','queued','running',...
            'finished',...
            'failed','unavailable','deleted'}
        par_cluster_state_codes_ = {0,1,2,3,4,...
            101,102,103}
        cluster_name2code = containers.Map(...
            ClusterParpoolWrapper.par_cluster_state_names_ ,...
            ClusterParpoolWrapper.par_cluster_state_codes_ )
        % List of states parallel computing toolbox may report
        %Pending     ( 'pending'     , 0  )
        %Paused      ( 'paused'      , 1  )
        %Queued      ( 'queued'      , 2  )
        %Running     ( 'running'     , 3  )
        %Finished    ( 'finished'    , 4  )
        % The following states are all >= Finished to ensure that "wait"s
        % terminate if the job fails or becomes unavailable.
        %Failed      ( 'failed'      , 101 )
        %Unavailable ( 'unavailable' , 102 )
        %Destroyed   ( 'deleted'     , 103 )
    end
    
    methods
        function obj = ClusterParpoolWrapper(n_workers,mess_exchange_framework)
            % Constructor, which initiates wrapper around Matlab Parallel
            % computing toolbox parallel capabilities.
            %
            % The wrapper provides common interface to run various kind of
            % Herbert parallel jobs.
            %
            % Empty constructor generates wrapper, which has to be
            % initiated by init method.
            %
            % Non-empty constructor calls the init method itself
            %
            % Inputs:
            % n_workers -- number of independent Matlab workers to execute
            %              a job
            % mess_exchange_framework -- a class-child of
            %              iMessagesFramework, used  for communications
            %              between cluster and the host Matlab session,
            %              which started and controls the job.
            %
            % log_level    if present, defines the verbosity of the
            %              operations over the framework
            obj = obj@ClusterWrapper();
            obj.starting_info_message_ = ...
                ':parpool configured: *** Starting Matlab MPI job  with %d workers ***\n';
            obj.started_info_message_  = ...
                '*** Matlab MPI job started                                 ***\n';
            obj.cluster_config_ = 'default';
            obj.pool_exchange_frmwk_name_ = 'MessagesParpool';
            if nargin < 2
                return;
            end
            if ~exist('log_level', 'var')
                log_level = -1;
            end
            obj = obj.init(n_workers,mess_exchange_framework,log_level);
        end
        %
        function obj = init(obj,n_workers,mess_exchange_framework,log_level)
            % Method to initiate/reinitiate empty Parpool class wrapper.
            % The method to initate the cluster wrapper
            %
            % Inputs:
            % n_workers -- number of independent Matlab workers to execute
            %              a job
            % mess_exchange_framework -- a class-child of
            %              iMessagesFramework, used  for communications
            %              between cluster and the host Matlab session,
            %              which started and controls the job.
            %log_level     if present, the number, which describe the
            %              verbosity of the cluster operations outpt;
            if ~exist('log_level', 'var')
                log_level = -1;
            end
            
            obj = init@ClusterWrapper(obj,n_workers,mess_exchange_framework,log_level);
            
            % delete interactive parallel cluster if any exist
            cl = gcp('nocreate');
            if ~isempty(cl)
                %clear up interactive pool if exist as this method will start
                %batch job.
                delete(cl);
            end
            % build generic worker init string without lab parameters
            cs = obj.mess_exchange_.get_worker_init(obj.pool_exchange_frmwk_name);
            pc = parallel_config;
            
            
            cl  = parcluster();
            cl.JobStorageLocation = pc.working_directory;
            
            % By default Matlab only utilises physical cores; enable use of
            % logical cores if required
            n_requested_workers = obj.n_workers;
            if n_requested_workers > cl.NumWorkers
                [~, n_logical_cores] = get_num_cores();
                if n_requested_workers <= n_logical_cores
                    cl.NumWorkers = n_requested_workers;
                end
            end
            
            num_labs = cl.NumWorkers;
            if num_labs < obj.n_workers
                error('HERBERT:ClusterParpoolWrapper:invalid_argument',...
                    'job %s requested %d workers while the cluster allows only %d',...
                    obj.job_id,obj.n_workers,num_labs);
            end
            cjob = createCommunicatingJob(cl,'Type','SPMD');
            
            if n_workers > 0
                cjob.NumWorkersRange  = obj.n_workers;
            end
            cjob.AutoAttachFiles = false;
            
            h_worker = str2func(obj.worker_name_);
            task = createTask(cjob,h_worker,0,{cs});
            
            obj.cluster_ = cl;
            obj.current_job_  = cjob;
            obj.task_ = task;
            
            [completed,obj] = obj.check_progress('-reset_call_count');
            if completed
                error('HERBERT:ClusterParpoolWrapper:runtime_error',...
                    'parpool cluster for job %s finished before starting any job. State: %s',...
                    obj.job_id,obj.status_name);
            end
            %actually submit the job
            submit(cjob);
            %wait(cjob);
            if log_level > -1
                fprintf(2,obj.started_info_message_);
            end
        end
        %
        function obj=finalize_all(obj)
            % Close the MPI job, delete filebased exchange folders
            % and complete parallel job
            obj = finalize_all@ClusterWrapper(obj);
            if ~isempty(obj.current_job_)
                delete(obj.current_job_);
                obj.current_job_ = [];
                obj.cluster_prev_state_ = obj.cluster_cur_state_;
                obj.cluster_cur_state_ = [];
                obj.status_changed_ = false;
            end
            
        end
        %
        function check_availability(obj)
            % verify the availability of the Matlab Parallel Computing
            % toolbox and the possibility to use the paropool cluster to
            % run parallel jobs.
            %
            % Should throw HERBERT:ClusterWrapper:not_available exception
            % if the particular framework is not avalable.
            %
            check_availability@ClusterWrapper(obj);
            check_parpool_can_be_enabled_(obj);
        end
        %
        function is = is_job_initiated(obj)
            % returns true, if the cluster wrapper is running communicating
            % job
            is = ~isempty(obj.task_);
        end
        %------------------------------------------------------------------
         
    end
    methods(Access = protected)
        function ex = exit_worker_when_job_ends_(~)
            ex  = false;
        end
        %         %
        function [running,failed,paused,mess]=get_state_from_job_control(obj)
            % retrieve the job state by accessing job control framework
            % and set current status accordingly
            %
            cljob = obj.current_job_;
            state = cljob.State;
            
            code = obj.cluster_name2code(state);
            if code == 3 % job is running
                running = true;
                failed = false;
                paused = false;
                mess = 'running';
                return;
            end
            if code < 3 || code == 4 % paused, pended, not yet started or finished (code==4)
                running = false;
                failed = false;
                if code < 3
                    mess = aMessage('queued');
                    paused = true;
                else
                    mess   = CompletedMessage();
                    paused = false;
                end
                return;
            end
            %  failed
            paused = false;
            running= false;
            failed = true;
            
            %ErrorMessage	Message from task error
            err = obj.task_.Error;
            %Error	Task error information
            messer_txt = obj.task_.ErrorMessage;
            %ErrorIdentifier	Task error identifier
            err_id = obj.task_.ErrorIdentifier;

            fail_text = sprintf('Cluster job: %s failed. Message: %s, Code: %d',obj.job_id,messer_txt,err_id);          
            if isa(err,'MException')
                rep_err = err;
            elseif ischar(err)
                if contains(err,':')
                    rep_err = MException(err,messer_txt);
                else
                    rep_err = MException(['HERBERT:',strrep(err,' ','_')],messer_txt);
                end
            else
                err = strtrim(evalc('disp(err)'));
                rep_err = MException(['HERBERT:ParpoolWrapper:',strrep(err,' ','_')],messer_txt);
            end
            mess   = FailedMessage(fail_text,rep_err);
        end
    end
    
end
