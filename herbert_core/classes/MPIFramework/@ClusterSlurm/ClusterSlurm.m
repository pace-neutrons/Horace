classdef ClusterSlurm < ClusterWrapper
    % The class to support cluster of Matlab workers, communicating over
    % MPI interface controlled by Slurm job manager.
    %
    %----------------------------------------------------------------------
    properties(Access = protected)
        % The slurm Job identifier
        slurm_job_id = [];
    end
    properties(Access = private)
        %
        DEBUG_REMOTE = false;
        srun_enviroment = containers.Map(...
            {'MATLAB_PARALLEL_EXECUTOR','PARALLEL_WORKER','WORKER_CONTROL_STRING'},...
            {'matlab','worker_v2',''});
    end
    
    methods
        function obj = ClusterSlurm(n_workers,mess_exchange_framework)
            % Constructor, which initiates MPI wrapper
            %
            % The wrapper provides common interface to run various kinds of
            % Herbert parallel jobs, communication over mpi (mpich)
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
                '**** Slurm MPI job submitted                                     ****\n';
            %
            obj.pool_exchange_frmwk_name_ ='MessagesCppMPI';
            obj.cluster_config_ = 'default';
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
            obj.srun_enviroment('MATLAB_PARALLEL_EXECUTOR') = ...
                '/opt/matlab2020b/bin/matlab';
            % what should be executed by Matlab parallel worker (will be
            % nothing if Matlab parallel worker is compiled)
            obj.srun_enviroment('PARALLEL_WORKER') =...
                sprintf('-batch %s',obj.worker_name_);
            % build worker init string describing the data exchange
            % location
            obj.srun_enviroment('WORKER_CONTROL_STRING') =...
                obj.mess_exchange_.get_worker_init(obj.pool_exchange_frmwk_name);
            %
            keys = obj.srun_enviroment.keys;
            vals = obj.srun_enviroment.values;
            cellfun(@(name,val)setenv(name,val),keys,vals);
            
            % modify executor script values to export it to remote slurm
            % session
            run_source = fullfile(herbert_root,'herbert_core','admin','srun_runner.sh');
            [fp,fon] = fileparts(mess_exchange_framework.mess_exchange_folder);
            runner= obj.set_run_params(run_source,...
                fullfile(fp,[fon,'.sh']));
            
            [fail,queue_state0] = system('squeue');
            if  fail
                error('HERBERT:ClusterSlurm:runtime_error',...
                    ' Can not execute initial slurm queue query. Error: %s',...
                    queue_state0);
            end
            
            run_str = [slurm_str{:},runner,' &'];
            [fail,mess]=system(run_str);
            if  fail
                error('HERBERT:ClusterSlurm:runtime_error',...
                    ' Can not execute srun command for %d workers, Error: %s',...
                    n_workers,mess);
            end
            
            %
            if log_level > -1
                fprintf(obj.started_info_message_);
            end
        end
        %
        function obj=finalize_all(obj)
            obj = finalize_all@ClusterWrapper(obj);
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
                if ~completed % the java framework reports job finished but
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
            % The function returns the list of the availible clusters
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
            % verify the availability of slurm cluster managment
            % and the possibility to use the slurm cluster
            % to run parallel jobs.
            %
            % Should throw HERBERT:ClusterWrapper:not_available exception
            % if the particular framework is not avalable.
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
    end
    methods(Static)
    end
    methods(Access = protected)
        function [ok,failed,mess] = is_running(~)
            % check if java process is still running or has been completed
            %
            ok = true;
            failed = false;
            mess = '';
        end
        
        function bash_target = set_run_params(obj,bash_source,bash_target)
            % modify executor script to set up enviromental variables necessary
            % to provide remote parallel job startup information
            [~,cont,var_pos] = extract_bash_exports(bash_source);
            cont = modify_contents(cont,var_pos,obj.srun_enviroment);
            fh = fopen(bash_target,'w');
            if fh<1
                error('HERBERT:ClusterSlurm:io_error',...
                    'Can not open filr %s to modify for job submission',...
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

