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
        % to appear in the queue.
        time_to_wait_for_job_id_=1;
        % the location of the end of the job status field, used for parsing
        % the job logs
        time_field_pos_
        % the user name, used to distinguish this user jobs from others
        user_name_
        % The header, returned by squeue command. Defined in the class for
        % purpose of parsing job logs in tests
        header_ = 'JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)';
    end
    properties(Access = private)
        %
        DEBUG_REMOTE = false;
        % environmental variables and their default values,
        % set by the class to propagate to a parallel job.
        slurm_enviroment = containers.Map(...
            {'MATLAB_PARALLEL_EXECUTOR','PARALLEL_WORKER','WORKER_CONTROL_STRING'},...
            {'matlab','worker_v2',''});
        % Job State description
        job_desctiption = containers.Map(...
            {'PD','R','CG','CD','F','TO','S','ST'},...
            {'Pending','Running','Completing','Completed','Failed',...
            'Terminated','Suspended','Stopped'});
        %PD   Pending     The job is waiting in a queue for allocation of resources
        %R    Running     The job currently is allocated to a node and is running
        %CG   Completing  The job is finishing but some processes are still active
        %CD   Completed   The job has completed successfully
        %F    Failed      Failed with non-zero exit value
        %TO   Terminated  Job terminated by SLURM after reaching its runtime limit
        %S    Suspended   A running job has been stopped with its resources released to other jobs
        %ST   Stopped     A running job has been stopped with its resources retained
        %
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
            %
            obj.pool_exchange_frmwk_name_ ='MessagesCppMPI';
            obj.cluster_config_ = 'default';
            obj=obj.init_parser();
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
            
            
            slurm_str = {'srun ',['-N',num2str(n_workers)],' --mpi=pmi2 '};
            % temporary hack. Matlab on nodes differs from Matlab on the
            % headnode. Should be contents of obj.matlab_starter_
            obj.slurm_enviroment('MATLAB_PARALLEL_EXECUTOR') = ...
                'matlab';
            %obj.matlab_starter_;%'/opt/matlab2020b/bin/matlab';
            % what should be executed by Matlab parallel worker (will be
            % nothing if Matlab parallel worker is compiled)
            obj.slurm_enviroment('PARALLEL_WORKER') =...
                sprintf('-batch %s',obj.worker_name_);
            % build worker init string describing the data exchange
            % location
            obj.slurm_enviroment('WORKER_CONTROL_STRING') =...
                obj.mess_exchange_.get_worker_init(obj.pool_exchange_frmwk_name);
            % set up job variables on local environment (Does not
            % currently used as ISIS implementation does not transfer
            % environmental variables to cluster)
            keys = obj.slurm_enviroment.keys;
            vals = obj.slurm_enviroment.values;
            cellfun(@(name,val)setenv(name,val),keys,vals);
            
            % modify executor script values to export it to remote Slurm
            % session
            run_source = fullfile(herbert_root,'herbert_core','admin','srun_runner.sh');
            [fp,fon] = fileparts(mess_exchange_framework.mess_exchange_folder);
            runner= obj.create_runparam_script(run_source,...
                fullfile(fp,[fon,'.sh']));
            obj.runner_script_name_  = runner;
            
            queue0_rows = obj.get_queue_info('-trim');
            
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
            
            %
            if log_level > -1
                fprintf(2,obj.started_info_message_,obj.slurm_job_id);
            end
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
            [ok,failed,mess] = obj.is_running();
            [completed,obj] = check_progress@ClusterWrapper(obj,varargin{:});
            if ~ok
                if ~completed % the Java framework reports job finished but
                    % the head node have not received the final messages.
                    completed = true;
                    mess_body = sprintf(...
                        'Framework launcher reports job finished without returning final messages. Reason: %s',...
                        mess);
                    if failed
                        obj.status = FailedMessage(mess_body);
                    else
                        c_mess = aMessage('completed');
                        c_mess.payload = mess_body;
                        obj.status = c_mess ;
                    end
                    me = obj.mess_exchange_;
                    me.clear_messages()
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
            config = {'default'};
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
            %[status,res] = system('command -v srun');
            status = system('command -v srun');
            if status ~= 0
                error('HERBERT:ClusterWrapper:not_available',...
                    'Slurm manager is not available or not on the search path of this machine');
            end
        end
        %------------------------------------------------------------------
        function id = get.slurm_job_id(obj)
            id = obj.slurm_job_id_;
        end
    end
    methods(Static)
    end
    methods(Access = protected)
        %
        function [ok,failed,mess] = is_running(obj)
            % check if the job is still in cluster
            %
            ok = true;
            failed = false;
            mess = '';
        end
        %
        function queue_rows = get_queue_info(obj,varargin)
            % Auxiliary function to return existing jobs queue list
            % Options:
            % '-full_header' -- job list should return the header
            % '-trim'        -- the job list should be trimmed up to job
            %                   run time (for identifying existing jobs
            %                   regardless of their run time)
            % '-for_this_job -- return the information for the job with
            %                   this job ID only
            opt = {'-full_header','-trim','-for_this_job'};
            [ok,mess,full_header,trim_strings,for_this_job] = parse_char_options(varargin,opt);
            if ~ok
                error('HERBERT:ClusterSlurm:invalid_argument',mess);
            end
            queue_rows = get_queue_info_(obj,full_header,trim_strings,for_this_job);
            
        end
        %
        function queue_text = get_queue_text_from_system(obj,full_header,job_with_this_id)
            % retrieve queue information from the system
            % Input keys:
            % full_header -- if true, job information should contain header
            %                describing the fields. if talse, only the
            %                job information itself is returned
            %job_with_this_id -- return information for the job with this
            %               id only. If false, all jobs for this users are
            %               returned.
            % Returns:
            % queue_text   -- the text, describing the state of the job
            %                 (squeue command output)
            if nargin<3
                job_with_this_id = false;
            end
            queue_text = get_queue_text_from_system_(obj,full_header,job_with_this_id);
        end
        %
        function obj=init_parser(obj)
            % initialize parameters, needed for job queue management
            
            % retrieve user name
            [fail,uname]=system('whoami');
            if fail
                error('HERBERT:ClusterSlurm:runtime_error',...
                    ' Can not retrieve user name. Error: %s',...
                    uname);
            end
            obj.user_name_ = strtrim(uname);
            % find the location of end of the SATUS string
            obj.time_field_pos_ = strfind(obj.header_,'ST ')+2;
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
            cont = modify_contents(cont,var_pos,obj.slurm_enviroment);
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
