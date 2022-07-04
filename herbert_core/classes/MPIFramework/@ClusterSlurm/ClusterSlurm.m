classdef ClusterSlurm < ClusterWrapper
    % The class to support cluster of Matlab workers, communicating over
    % MPI interface controlled by Slurm job manager.
    %
    %----------------------------------------------------------------------
    properties(Access = public)
        slurm_job_id
    end
    properties(Access = protected)
        % The Slurm Job identifier
        slurm_job_id_ = [];
        % name of the script, which launches the particular Slurm job
        runner_script_name_ = '';
        %-----------------------------------------------------------------
        % Private parameters exposed as protected for testing
        %
        % The time (in sec) to wait from job submission to asking for job
        % getting allocation under normal cirumnstances
        time_to_wait_for_job_running_=2;
        % the user name, used to distinguish this user jobs from others
        user_name_
        % verbosity of ClusterSlurm specific outputs
        log_level = 0;
    end
    properties(Constant, Access = private)
        %------------------------------------------------------------------
        % sacct state description list:
        %BF BOOT_FAIL   Job terminated due to launch failure, typically due to a hardware failure (e.g. unable to boot the node or block and the job can not be requeued).
        %CA CANCELLED   Job was explicitly cancelled by the user or system administrator. The job may or may not have been initiated.
        %CD COMPLETED   Job has terminated all processes on all nodes with an exit code of zero.
        %CF CONFIGURING Job has been allocated resources, but are waiting for them to become ready for use (e.g. booting).
        %CG COMPLETING  Job is in the process of completing. Some processes on some nodes may still be active.
        %DL DEADLINE    Job missed its deadline.
        %F FAILED       Job terminated with non-zero exit code or other failure condition.
        %NF NODE_FAIL   Job terminated due to failure of one or more allocated nodes.
        %PD PENDING     Job is awaiting resource allocation. Note for a job to be selected in this state it must have "EligibleTime" in the requested time interval or different from "Unknown". The "EligibleTime" is displayed by the "scontrol show job" command. For example jobs submitted with the "--hold" option will have "EligibleTime=Unknown" as they are pending indefinitely.
        %PR PREEMPTED   Job terminated due to preemption.
        %R RUNNING      Job currently has an allocation.
        %RS RESIZING    Job is about to change size.
        %S SUSPENDED    Job has an allocation, but execution has been suspended.
        %TO TIMEOUT     Job terminated upon reaching its time limit.
        % Expected outputs can be:
        % RUNNING, RESIZING, SUSPENDED, PENDING, COMPLETED, CANCELLED, FAILED,
        % TIMEOUT, PREEMPTED, BOOT_FAIL, DEADLINE or NODE_FAIL
        %
        sacct_state_abbr_ =  {'RU','RE','SU','PE','CO','CA','FA','TI','PR','BO','DE','NO','PD'}
        sjob_long_description_ = containers.Map(ClusterSlurm.sacct_state_abbr_ ,...
            {'Job currently has an allocation and running.',...
            'Job is about to change size.',...
            'Job has an allocation, but execution has been suspended.',...
            'Job is in the process of allocation, and execution is pending',...
            'Job has terminated all processes on all nodes with an exit code of zero.',...
            'Job was explicitly cancelled by the user or system administrator. The job may or may not have been initiated.',...
            'Job terminated with non-zero exit code or other failure condition.',...
            'Job terminated upon reaching its time limit.',...
            'Job terminated due to preemption.',...
            'Job terminated due to launch failure, typically due to a hardware failure (e.g. unable to boot the node or block and the job can not be requeued).',...
            'Job missed its deadline.',...
            'Job terminated due to failure of one or more allocated nodes.',...
            'Nodes required for job are DOWN, DRAINED or reserved for jobs in higher priority jobs'
            })
        sjob_reaction_ = containers.Map(ClusterSlurm.sacct_state_abbr_,...
            {'running','paused','paused','paused','finished','failed','failed','failed',...
            'failed','failed','failed','failed','failed'})        
    end
    
    
    methods
        function obj = ClusterSlurm(n_workers,mess_exchange_framework,...
                log_level)
            % Constructor, which initiates MPI wrapper
            %
            % The wrapper provides common interface to run various kinds of
            % Herbert parallel jobs, communication over MPI (mpich)
            %
            % Empty constructor generates wrapper, which has to be
            % initiated by init method.
            %
            % Non-empty constructor calls the init method itself
            %
            % Inputs:
            % n_workers -- number of independent Matlab workers to execute
            %              a job
            %
            % mess_exchange_framework -- a class-child of
            %              iMessagesFramework, used  for communications
            %              between cluster and the host Matlab session,
            %              which started and controls the job.
            %
            % log_level    if present, defines the verbosity of the
            %              operations over the framework
            obj = obj@ClusterWrapper();
            obj.starting_info_message_ = ...
                '**** Slurm MPI job configured,  Starting MPI job  with %d workers ****\n';
            obj.started_info_message_  = ...
                '**** Slurm MPI job with ID: %10d submitted                 ****\n';
            
            % The default name of the messages framework, used for communications
            % between the nodes of the parallel job
            obj.pool_exchange_frmwk_name_ ='MessagesCppMPI';
            % two configurations are expected, namely 'srun', where the job
            % is run and controlled by 'srun' command and 'sbatch' where the
            % job is controlled by 'sbatch' command
            % the scripts, which
            obj.cluster_config_ = 'srun';
            % initiate parameters necessary for job queue parsing
            obj=obj.init_queue_parser();
            obj.starting_cluster_name_ = class(obj);
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
            % The method to initiate the cluster wrapper and start running
            % the cluster job.
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
            obj = init@ClusterWrapper(obj,n_workers,mess_exchange_framework,log_level);
            obj.log_level = log_level;
            
            
            slurm_str = {'srun ',['-N',num2str(n_workers)],' --mpi=pmi2 '};
            %
            % May change for compiled Horace
            obj.common_env_var_('HERBERT_PARALLEL_WORKER') =...
                sprintf('-batch %s',obj.worker_name_);
            % build worker init string describing the data exchange
            % location
            obj.common_env_var_('WORKER_CONTROL_STRING') =...
                obj.mess_exchange_.get_worker_init(obj.pool_exchange_frmwk_name);
            %
            % set up job variables on local environment (Does not
            % currently used as ISIS implementation does not transfer
            % environmental variables to cluster)
            obj.set_env();
           
            % modify executor script values to export it to remote Slurm
            % session
            run_source = fullfile(herbert_root,'herbert_core','admin','srun_runner.sh');
            [fp,fon] = fileparts(mess_exchange_framework.mess_exchange_folder);
            % the enviromental variables are transferred and stored and set
            % in the shel script
            runner= obj.create_runparam_script(run_source,...
                fullfile(fp,[fon,'.sh']));
            obj.runner_script_name_  = runner;
            
            queue0_rows = obj.get_queue_info();
            
            run_str = [slurm_str{:},runner,' &'];
            %run_str = [slurm_str{:},runner];
            [failed,mess]=system(run_str);
            if failed
                error('HERBERT:ClusterSlurm:runtime_error',...
                    ' Can not execute srun command for %d workers, Error: %s',...
                    n_workers,mess);
            end
            % parse queue and extract new job ID
            obj = extract_job_id(obj,queue0_rows);
            obj.starting_cluster_name_ = sprintf('SlurmJobID%d',obj.slurm_job_id);
            
            % check if job control API reported failure
            pause(obj.time_to_wait_for_job_running_);
            obj.check_failed();
            
        end
        %
        function obj=finalize_all(obj)
            % complete parallel job execution
            
            % close exchange framework and delete exchange folder
            obj = finalize_all@ClusterWrapper(obj);
            if ~isempty(obj.runner_script_name_)
                % delete script used to run the Slurm job
                delete(obj.runner_script_name_);
                obj.runner_script_name_ = '';
                % cancel parallel job
                [failed,mess]=system(['scancel ',num2str(obj.slurm_job_id_)]);
                if failed
                    error('HERBERT:ClusterSlurm:runtime_error',...
                        'Error cancelling Slurm job with ID %d, Reason: %s',...
                        obj.slurm_job_id_,mess);
                end
            end
        end
        %
        function config = get_cluster_configs_available(~)
            % The function returns the list of the available clusters
            % to run using correspondent parallel framework.
            %
            % The clusters defined by the list of the available host files.
            %
            % The first configuration in the available clusters list would
            % be the default configuration.
            %
            config = {'srun','sbatch'};
        end
        %
        function check_availability(obj)
            % verify the availability of Slurm cluster management
            % and the possibility to use the Slurm cluster
            % to run parallel jobs.
            %
            % Should throw HERBERT:ClusterWrapper:not_available exception
            % if the particular framework is not available.
            %
            check_availability@ClusterWrapper(obj);
            if ~isunix
                error('HERBERT:ClusterWrapper:not_available',...
                    'Slurm job manager available on Unix only');
            end
            % keep res variable as it print it otherwise
            [status,res] = system('command -v srun');
            if status ~= 0
                error('HERBERT:ClusterWrapper:not_available',...
                    'Slurm manager is not available or not on the search path of this machine');
            end
        end
        %------------------------------------------------------------------
        function id = get.slurm_job_id(obj)
            id = obj.slurm_job_id_;
        end
        %
        function is = is_job_initiated(obj)
            % returns true, if the cluster wrapper is responsible for a job
            is = ~isempty(obj.slurm_job_id_);
        end
        %
    end
    methods(Static)
    end
    methods(Access = protected)
        %
        function [running,failed,paused,mess]=get_state_from_job_control(obj)
            % check if the job is still on the cluster and running and
            % return the job state and the information about this state
            %
            [sacct_state,full_state] = query_control_state(obj,false);
            % Debugging operation. Seems not all states are described in
            % manual
            states = obj.sjob_reaction_.keys;
            if ~ismember(sacct_state,states)
                if obj.log_level>-1
                    fprintf(2,'*** SLURM control returned unknown state: %s,\n',...
                        sacct_state)
                    fprintf(2,'*** Description:\n %s\n',...
                        full_state);
                    fprintf(2,'*** Assuming job: %s, Slurm Job id: %d is paused\n',...
                        obj.job_id,obj.slurm_job_id);
                end
                control_state = 'paused';
                description = sprintf('*** Unknown state %s considered job %s paused',...
                    full_state,obj.job_id);
            else
                if strcmp(sacct_state,'PE')
                    sacct_state = check_pending_state_(obj,sacct_state);
                end
                control_state = obj.sjob_reaction_(sacct_state);
                description = obj.sjob_long_description_(sacct_state);
            end
            switch(control_state)
                case 'running'
                    running = true;
                    failed  = false;
                    paused  = false;
                    mess    = 'running';
                case 'failed'
                    running = false;
                    failed  = true;
                    paused  = false;
                    mess = FailedMessage(description );
                case 'finished'
                    running = false;
                    failed  = false;
                    paused  = false;
                    mess = CompletedMessage(description);
                case 'paused'
                    running = false;
                    failed  = false;
                    paused  = true;
                    mess = LogMessage(0,0,0,description);
                otherwise % Never happens
                    error('HERBERT:ClusterSlurn:runtime_error',...
                        'Undefined sacct control state %s',description);
            end
        end
        %
        function [sacct_state,full_state] = query_control_state(obj,debug_state)
            % retrieve the state of the job issuing Slurm sacct
            % query command and parsing the results
            %
            % Protected function to overload for testing
            %
            [sacct_state,full_state] = query_control_state_(obj,debug_state);
        end
        %
        function queue_rows = get_queue_info(obj,varargin)
            % Auxiliary function to return existing jobs queue list
            opt = {'-full_header'};
            [ok,mess,full_header] = parse_char_options(varargin,opt);
            if ~ok
                error('HERBERT:ClusterSlurm:invalid_argument',mess);
            end
            queue_rows = get_queue_info_(obj,full_header);
            
        end
        %
        function queue_text = get_queue_text_from_system(obj,full_header)
            % retrieve queue information from the system
            % Input keys:
            % full_header -- if true, job information should contain header
            %                describing the fields. if talse, only the
            %                job information itself is returned
            % Returns:
            % queue_text   -- the text, describing the state of the job
            %                 (squeue command output)
            queue_text = get_queue_text_from_system_(obj,full_header);
        end
        %
        function obj=init_queue_parser(obj)
            % initialize parameters, needed for job queue management
            
            % retrieve user name
            [fail,uname]=system('whoami');
            if fail
                error('HERBERT:ClusterSlurm:runtime_error',...
                    ' Can not retrieve user name. Error: %s',...
                    uname);
            end
            obj.user_name_ = strtrim(uname);
        end
        %
        function  obj = extract_job_id(obj,old_queue_rows)
            % Retrieve job queue logs from the system
            % and extract new job ID from the log
            %
            % Inputs:
            % old_queue_rows -- the cellarray of rows, which contains the
            %                   job logs, obtained before new job was
            %                   submitted
            % Returns:
            % cluster object with slurm_job_id property set.
            obj = extract_job_id_(obj,old_queue_rows);
        end
        %
        function bash_target = create_runparam_script(obj,bash_source,bash_target)
            % modify executor script to set up enviromental variables necessary
            % to provide remote parallel job startup information
            %
            [~,cont,var_pos] = extract_bash_exports(bash_source);
            cont = modify_contents(cont,var_pos,obj.common_env_var_);
            fh = fopen(bash_target,'w');
            if fh<1
                error('HERBERT:ClusterSlurm:io_error',...
                    'Can not open file %s to modify for job submission',...
                    bash_source);
            end
            clOb = onCleanup(@()fclose(fh));
            for i=1:numel(cont)
                fprintf(fh,'%s\n',cont{i});
            end
            clear clOb;
            [fail,mess] = system(['chmod a+x ',bash_target]);
            if fail
                error('HERBERT:ClusterSlurm:runtime_error',...
                    'Can not set up executable mode for file %s. Readon: %s',...
                    bash_target,mess);
            end
        end
    end
    
end
