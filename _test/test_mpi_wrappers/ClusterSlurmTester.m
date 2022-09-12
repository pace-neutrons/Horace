classdef ClusterSlurmTester < ClusterSlurm
    % Helper class to test ClusterSlurm protected methods

    properties
        % the results of squeue command,
        squeue_command_output
        % the results of sacct command
        sacct_command_output
    end



    methods
        function obj = ClusterSlurmTester(n_workers,mess_exchange_framework,log_level)
            % Constructor, which initiates Slurm wrapper
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
            % mess_exchange_framework -- ignored here
            %
            % log_level    if present, defines the verbosity of the
            %              operations over the framework
            obj = obj@ClusterSlurm();
            obj.time_to_wait_for_job_running_ = 0;

            if ~exist('log_level', 'var')
                hc = herbert_config;
                log_level = hc.log_level;
                obj.log_level = log_level;
            end

            if nargin < 2
                return;
            end
            obj = obj.init(n_workers,mess_exchange_framework,log_level);
        end

        function obj = init(obj,n_workers,mess_exchange_framework,log_level)
            wk_folder = mess_exchange_framework.mess_exchange_folder;
            init_struct = iMessagesFramework.build_worker_init(wk_folder, ...
                'test_FB_message', 'MessagesFilebased', 1, n_workers,'test_mode');

            mess_exchange_framework = MessagesFileBasedMPI_mirror_tester(init_struct);
            obj = init@ClusterWrapper(obj,n_workers,mess_exchange_framework,log_level);
        end

        function obj = extract_job_id_tester(obj)
            % exposes protected method for testing purposes
            obj = obj.extract_job_id();
        end

        function user_name= init_parser_tester(obj)
            % function to test init parser:
            % Returns:
            % user_name -- the name of the user running the session
            % pos       -- the position of the beginning of the running
            %              time field.
            obj = obj.init_queue_parser();
            user_name = obj.user_name_;
        end

        function [running,failed,paused,mess]=get_state_from_job_control_tester(obj)
            % method to test get_state_from_job_control, using squeue_command_output
            % value as the input for queue
            [running,failed,paused,mess] = obj.get_state_from_job_control();
        end
    end

    methods(Access=protected)
        function queue_text = get_queue_text_from_system(obj,full_header)
            % last parameter is ignored as this test method returns
            % whatever is set to squeue_command_output
            if full_header
                squeue_header = 'JOBID PARTITION NAME USER ST';
                queue_text =[sprintf('%s\n',squeue_header),obj.squeue_command_output];
            else
                queue_text = obj.squeue_command_output;
            end
        end

        function [sacct_state,description] = query_control_state(obj,varargin)
            % retrieve the state of the job retrieving fake Slurm sacct
            % query command and parsing the results
            %
            [sacct_state,description] = query_control_state@ClusterSlurm(obj,true);
        end
    end
end
