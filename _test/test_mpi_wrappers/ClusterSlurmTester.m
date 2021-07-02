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
            obj.time_to_wait_for_job_id_ = 0;
            
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
        %
        function obj = extract_job_id_tester(obj,old_queue_rows)
            % exposes protected method for testing purposes
            obj = obj.extract_job_id(old_queue_rows);
        end
        function head = get_header(obj)
            head = obj.squeue_header_;
        end
        function [user_name,pos]= init_parser_tester(obj)
            % function to test init parser:
            % Returns:
            % user_name -- the name of the user running the session
            % pos       -- the position of the begining of the running
            %              time field.
            obj = obj.init_parser();
            user_name = obj.user_name_;
            pos = obj.time_field_pos_;
        end
    end
    methods(Static)
    end
    methods(Access=protected)
        function queue_text = get_queue_text_from_system(obj,full_header,for_this_job)
            % last parameter is ignored as this test method returns
            % whatever is set to squeue_command_output
            if full_header
                queue_text =[sprintf('%s\n',obj.header_),obj.squeue_command_output];
            else
                queue_text = obj.squeue_command_output;
            end
        end
    end
end

