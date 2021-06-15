classdef ClusterSlurmTester < ClusterSlurm
    % Helper class to test ClusterSlurm protected methods
    
    properties
        % the results of squeue command,
        squeue_command_output
    end
    
    methods
        function obj = ClusterSlurmTester(n_workers,mess_exchange_framework,log_level)
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
            obj = obj@ClusterSlurm();
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
            wk_folder = mess_exchange_framework.mess_exchange_folder;
            init_struct = iMessagesFramework.build_worker_init(wk_folder, ...
                'test_FB_message', 'MessagesFilebased', 1, n_workers,'test_mode');
            
            mess_exchange_framework = MessagesFileBasedMPI_mirror_tester(init_struct);
            obj = init@ClusterWrapper(obj,n_workers,mess_exchange_framework,log_level);
        end
        function queue_rows = get_queue(obj)
            % Auxiliary funtion to return existing jobs queue list
            %             [fail,queue_list] = system('squeue --noheader');
            %             if  fail
            %                 error('HERBERT:ClusterSlurm:runtime_error',...
            %                     ' Can not execute second slurm queue query. Error: %s',...
            %                     new_queue);
            %             end
            queue_list = obj.squeue_command_output;
            queue_rows = strsplit(queue_list,{'\n','\r'},'CollapseDelimiters',true);
        end
        %
        function obj = extract_job_id_tester(obj,old_queue_rows)
            % exposes protected method for testing purposes
            obj = obj.extract_job_id(old_queue_rows);
        end
        
    end
    methods(Static)
    end
end

