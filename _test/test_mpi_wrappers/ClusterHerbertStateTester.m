classdef ClusterHerbertStateTester < ClusterHerbert
    % Helper class to test ClusterHerbert states derived from
    % cluster.
    %
    % Overloads init method to communicate via reflective framework
    % and sets up job control to return state from the inputs, provided to
    % init_state propetry
    
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
        function obj = ClusterHerbertStateTester(n_workers,log_level)
            % Constructor, which initiates fake MPI wrapper
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
            % log_level    if present, defines the verbosity of the
            %              operations over the framework
            obj = obj@ClusterHerbert();
            
            if nargin < 1
                return;
            end
            
            if ~exist('log_level', 'var')
                log_level = -1;
            end
            obj = obj.init(n_workers,[],log_level);
        end
        %
        function obj = init(obj,n_workers,mess_exchange_framework,log_level)
            if ~exist('log_level', 'var')
                log_level = -1;
            end
            control_struc = iMessagesFramework.build_worker_init(tmp_dir, ...
                'test_ClusterHerbertStates',...
                'MessagesFilebased', 0,n_workers,'test_mode');
            meexch = MessagesFileBasedMPI_mirror_tester(control_struc);
            
            obj = init@ClusterWrapper(obj,n_workers,meexch,log_level);
            
            obj.tasks_handles_ = cell(1,n_workers);
            for i=1:n_workers
                obj.tasks_handles_{i} = fake_handle_for_test();
            end                      
            
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
                obj.tasks_handles_= [];
            end
        end
    end
    methods(Access = protected)
        function [running,failed,paused,mess] = get_state_from_job_control(obj)
            % Method checks if java framework is running
            %
            paused = false;
            mess = 'running';
            running = true;
            failed = false;
            if strcmp(obj.init_state_,'failed')
                running = false;
                failed = true;                
                mess = FailedMessage('Simulated Failure');
            end
            % this never happens in real poor man MPI cluster as it has no
            % way of indentifying the non-running and not failed cluster
            % introduced to satisfy more complex cluster types, which provide
            % such  possibility
            if strcmp(obj.init_state_,'finished')
                running = false;
                mess = CompletedMessage('Successful completeon');
            end
            
        end
        %
        
    end
    
end

