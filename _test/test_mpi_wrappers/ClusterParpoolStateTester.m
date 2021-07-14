classdef ClusterParpoolStateTester < ClusterParpoolWrapper
    % Helper class to test ClusterParpoolWrapper states derived from
    % cluster.
    %
    % Overloads init method to communicate via reflective framework
    % and sets up job control to return state from the inputs, provided to
    % init_state property
    
    properties(Dependent)
        % the state, fake cluster comes into after initialization
        init_state
    end
    properties
        % expose parpool cluster properties, initiated by fake job instead
        % of the real one, initiated by parallel computing toolbox job and
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
            % The wrapper provides fake diagnostics methods representing
            % behaviour of diagnostics provided by Matlab parallel computing
            % toolbox Job control classes
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
            control_struc = struct(...
                'job_id','test_ParpoolClusterStates',...
                'labID',0,...
                'numLabs',n_workers);
            meexch = MessagesMatlabMPI_tester(control_struc);
            obj = init@ClusterWrapper(obj,n_workers,meexch,log_level);
            
            obj.init_state = obj.init_state_;
            %
            % check if job control API reported failure
            obj.check_failed();
            
        end
        function obj=finalize_all(obj)
            % Close the MPI job, delete filebased exchange folders
            % and complete parallel job
            if ~isempty(obj.current_job_)
                obj.current_job_ = [];
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
        %
        function obj=set.init_state(obj,val)
            if strcmpi(val,'failed')
                obj.task_ = struct('Error','Job failed',...
                    'ErrorMessage','Simulated failure',...
                    'ErrorIdentifier',-1);
            elseif strcmpi(val,'init_failed')
                obj.task_ = [];
            else
                obj.task_ = struct('Error','',...
                    'ErrorMessage','',...
                    'ErrorIdentifier',0);
            end
            obj.init_state_ = val;
            obj.current_job_ = struct('State',obj.init_state_);
        end
    end
end
