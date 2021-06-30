classdef ClusterParpoolStateTester < ClusterParpoolWrapper
    % Helper class to test ClusterParpoolWrapper states derived from
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
        % expose parpool cluster properties, initiated by fake job instead
        % of the real one, intiated by parallel computing toolbox job and
        % task classes
        current_job;
        task;
    end
    properties(Access=protected)
        init_state_ = 'queued';
        Error_ = ''
        ErrorMessage_ = '';
        ErrorIdentifier_ = 0;
    end
    
    methods
        function obj = ClusterParpoolStateTester(n_workers,log_level)
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
            obj = obj@ClusterParpoolWrapper();
            
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
            control_struc = struct('job_id','test_ParpoolClusterStates',...
                        'labID',0,'numLabs',n_workers);            
            meexch = MessagesMatlabMPI_tester(control_struc);
            obj = init@ClusterWrapper(obj,n_workers,meexch,log_level);
            
            obj.init_state = obj.init_state_;
            
            [completed,obj] = obj.check_progress('-reset_call_count');
            if completed
                error('HERBERT:ClusterParpoolWrapper:system_error',...
                    'parpool cluster for job %s finished before starting any job. State: %s',...
                    obj.job_id,obj.status_name);
            end
            if log_level > -1
                fprintf(obj.started_info_message_);
            end
            
        end
        %
        function job= get.current_job(obj)
            job = obj.current_job_;
        end
        function task = get.task(obj)
            task = obj.task_;
        end
        function state=get.init_state(obj)
            state = obj.init_state_;
        end
        function obj=set.init_state(obj,val)
            if strcmpi(val,'failed')
                obj.init_state_ = 'failed';
                obj.task_ = struct('Error','Job failed',...
                    'ErrorMessage','Simulated failure',...
                    'ErrorIdentifier',-1);
                
            else
                obj.init_state_ = val;
                obj.task_ = struct('Error','',...
                    'ErrorMessage','',...
                    'ErrorIdentifier',0);
            end
            obj.current_job_ = struct('State',obj.init_state_);
        end
        
        
    end  
end

