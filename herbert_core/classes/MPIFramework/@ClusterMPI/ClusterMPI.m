classdef ClusterMPI < ClusterWrapper
    % The class to support cluster of Matlab workers, communicating over
    % MPI interface started by by mpiexec.
    %
    %----------------------------------------------------------------------
    properties(Access = protected)
        
        % the string containing Java handle to running mpiexec process
        mpiexec_handle_ = [];
        %
    end
    properties(Access = private)
        % the folder, containing mpiexec cluster configurations (host files)
        config_folder_
    end
    
    methods
        function obj = ClusterMPI(n_workers,mess_exchange_framework)
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
                '**** mpiexec MPI job configured,  Starting MPI job  with %d workers ****\n';
            obj.started_info_message_  = ...
                '**** mpiexec MPI job submitted                                     ****\n';
            %
            % The default name of the messages framework, used for communications
            % between the nodes of the parallel job
            obj.pool_exchange_frmwk_name_ ='MessagesCppMPI';
            obj.cluster_config_ = 'local';
            % define config folder containing cluster configurations
            root = fileparts(which('herbert_init'));
            obj.config_folder_ = fullfile(root,'admin','mpi_cluster_configs');
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
            
            %
            mpiexec = obj.get_mpiexec();
            mpiexec_str = {mpiexec,'-n',num2str(n_workers)};
            
            % build generic worker init string without lab parameters
            cs = obj.mess_exchange_.get_worker_init(obj.pool_exchange_frmwk_name);
            worker_init = sprintf('%s(''%s'');exit;',obj.worker_name_,cs);
            task_info = [mpiexec_str(:)',...
                {obj.common_env_var_('HERBERT_PARALLEL_EXECUTOR')},...
                {'-batch'},{worker_init}];
            % this not used by java launcher bug may be used if we
            % decide to run parallel worker from script
            %obj.common_env_var_('HERBERT_PARALLEL_WORKER')= strjoin(task_info,' ');
            % encoded information about the location of exchange folder
            % and the parameters of the proceses pool.
            obj.common_env_var_('WORKER_CONTROL_STRING') = cs;
            %
            % prepate and start java process
            if ispc()
                runtime = java.lang.ProcessBuilder('cmd.exe');
            else
                runtime = java.lang.ProcessBuilder('/bin/sh');
            end
            env = runtime.environment();
            obj.set_env(env);
            % TODO:
            % this command does not currently transfer all necessary
            % enviromental variables to the remote. The procedure
            % to provide variables to transfer is MPI version specific
            % for MPICH it is the option of MPIEXEC: -envlist <list>
            % If mpiexec is used on a cluster, thos or similar option
            % for other mpi implementation should be implemented
            runtime = runtime.command(task_info);
            obj.mpiexec_handle_ = runtime.start();
            
            % check if job control API reported failure
            obj.check_failed();
            
        end
        %
        function obj=finalize_all(obj)
            obj = finalize_all@ClusterWrapper(obj);
            if ~isempty(obj.mpiexec_handle_)
                obj.mpiexec_handle_.destroy();
                obj.mpiexec_handle_ = [];
            end
        end
        %
        function config = get_cluster_configs_available(obj)
            % The function returns the list of the availible clusters
            % to run using correspondent parallel framework.
            %
            % The clusters defined by the list of the available host files.
            %
            % The first configuration in the available clusters list would
            % be the default configuration.
            %
            config = find_and_return_host_files_(obj);
        end
        
        %
        function check_availability(obj)
            % verify the availability of the compiled Herbert MPI
            % communicaton library and the possibility to use the MPI cluster
            % to run parallel jobs.
            %
            % Should throw HERBERT:ClusterWrapper:not_available exception
            % if the particular framework is not avalable.
            %
            check_availability@ClusterWrapper(obj);
            check_mpi_mpiexec_can_be_enabled_(obj);
        end
        %
        function is = is_job_initiated(obj)
            % returns true, if the cluster wrapper is mpiexec job
            is = ~isempty(obj.mpiexec_handle_);
        end
        %------------------------------------------------------------------
    end
    methods(Static)
        function mpi_exec = get_mpiexec()
            mpi_exec  = config_store.instance().get_value('parallel_config','external_mpiexec');
            if ~isempty(mpi_exec)
                if is_file(mpi_exec) % found external mpiexec
                    return
                else
                    warning('HERBERT:ClusterMPI:invalid_argument',...
                        'External mpiexec %s selected but is not available',mpi_exec);
                end
            end
            
            rootpath = fileparts(which('herbert_init'));
            external_dll_dir = fullfile(rootpath, 'DLL','external');
            if ispc()
                % only one version of mpiexec is used now. May change in the
                % future.
                mpi_exec = fullfile(external_dll_dir, 'mpiexec.exe');
            else
                mpi_exec = fullfile(external_dll_dir, 'mpiexec');
                
                if ~(is_file(mpi_exec))
                    % use system-defined mpiexec
                    [~, mpi_exec] = system('which mpiexec');
                    % strip non-printing characters, spaces and eol/cr-s from the
                    % end of mpiexec string.
                    mpi_exec = regexprep(mpi_exec,'[\x00-\x20\x7F-\xFF]$','');
                end
            end
        end
    end
    methods(Access = protected)
        function [running,failed,paused,mess] = get_state_from_job_control(obj)
            % check if java process is still running or has been completed
            %
            % inputs:
            paused = false;
            task_handle = obj.mpiexec_handle_;
            [running,failed,mess] = obj.is_java_process_running(task_handle);
            if failed
                mess = FailedMessage(mess);
            else % not failed
                if ~running
                    mess = CompletedMessage(mess);
                end
            end
        end
    end
end
