classdef ClusterSlurmStateTester < ClusterSlurm
    % Helper class to test ClusterSlurm states obtained from
    % running MPI job submitted by srun (or sbatch in a future).
    %
    % Overloads init method to communicate via reflective framework
    % and sets up job control to return state from the inputs, provided to
    % init_state property.
    
    properties(Dependent)
        % the state, fake cluster comes into after initialization
        init_state
    end
    properties
        
    end
    properties(Access=protected)
        init_state_ = 'running';
    end
    
    methods
        function obj = ClusterSlurmStateTester(n_workers,log_level)
            % Constructor, which initiates fake SlurmCluster wrapper
            %
            % The wrapper provides fake diagnostics methods representing
            % behaviour of diagnostics provided by Slurm cluster managment
            % software
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
            % log_level    if present, defines the verbosity of the
            %              operations over the framework
            obj = obj@ClusterSlurm();
            
            if nargin < 1
                return;
            end
            
            if ~exist('log_level', 'var')
                hc = herbert_config;
                log_level = hc.log_level;
            end
            obj = obj.init(n_workers,[],log_level);
        end
        %
        function obj = init(obj,n_workers,mess_exchange_framework,log_level)
            if ~exist('log_level', 'var')
                hc = herbert_config;
                log_level = hc.log_level;
            end
            control_struc = iMessagesFramework.build_worker_init(tmp_dir, ...
                'test_ClusterMPIStates',...
                'MessagesCppMPI_tester', 0,n_workers,'test_mode');
            meexch = MessagesCppMPI_tester(control_struc);
            
            obj = init@ClusterWrapper(obj,n_workers,meexch,log_level);
            
            % job runs with ID 100
            obj.slurm_job_id_ = 100;
            
            obj.init_state = obj.init_state_;
            
            % check if job control API reported failure
            obj.check_failed();
            
        end
        %
        function state=get.init_state(obj)
            state = obj.init_state_;
        end
        function obj=set.init_state(obj,val)
            obj.init_state_ = val;
            if strcmpi(val,'init_failed')
                obj.slurm_job_id_ = [];
            end
        end
    end
    methods(Access = protected)
        function [running,failed,paused,mess] = get_state_from_job_control(obj)
            % method check the situations presumably returned by Slurm job
            % control operations
            %
            switch(obj.init_state_)
                case 'failed'
                    running = false;
                    failed  = true;
                    paused  = false;
                    mess = FailedMessage('Simulated Failure');
                case 'finished'
                    running = false;
                    failed  = false;
                    paused  = false;
                    mess = CompletedMessage('Successful completion');
                case 'paused'
                    running = false;
                    failed  = false;
                    paused  = true;
                    mess = LogMessage(0,0,0,' Testing pause state');
                otherwise % running
                    running = true;
                    failed  = false;
                    paused  = false;
                    mess    = 'running';
            end
        end
        %
    end
end
