classdef MPI_State<handle
    % Helper class, to identify status of Matlab job, namely if current
    % Matlab session is independent session or is deployed by Herbert MPI
    % framework, and to help to deploy methods, which would depend on such
    % status, including access to messages framework to exchange messages
    % between various tasks.
    %
    % 'MPI-deployed' state is set up in worker.m (.template file is provided in
    % admin folder, to rename to the file with .m extension and
    % place to Matlab search path). The state should be checked by the client,
    % inheriting from JobExecutor within the loop executed within do_job method.
    %
    % Implemented as classical singleton.
    
    properties(Dependent)
        % report if the Matlab session is deployed on a remote worker
        is_deployed
        % logger function to deploy to log activities
        logger
        % the function to run verifying if job has been cancelled
        check_cancelled;
        % method helps to identify that the framework is tested and to
        % disable some framework capability, which should be used in this
        % situation
        is_tested
        % current active message exchange framework for advanced messages
        % exchange.
        mpi_framework;
    end
    properties(Access=protected)
        is_deployed_=false;
        logger_ = [];
        check_cancelled_=[];
        is_tested_ = false;
        % variables, used to identify time intervals between subsequent
        % calls to logging function
        start_time_=[];
        prev_time_interval_ = 0;
        mpi_framework_ = [];
    end
    properties(Constant, Access=protected)
        % methods to set using setattr method
        field_names_ = {'is_deployed','is_tested',...
            'logger','check_cancelled',...
            'mpi_framework'}
    end
    %----------------------------------------------------------------------
    methods(Access=private)
        function obj=MPI_State()
        end
    end
    %----------------------------------------------------------------------
    methods(Static)
        function obj = instance(varargin)
            persistent obj_state;
            if nargin>0 && ischar(varargin{1}) && strcmpi(varargin{1},'clear')
                obj_state = [];
            end
            if isempty(obj_state)
                obj_state = MPI_State();
            end
            obj=obj_state;
        end
    end
    %----------------------------------------------------------------------
    methods
        %------------------------------------------------------
        function is = get.is_deployed(obj)
            is = obj.is_deployed_;
        end
        function is = get.is_tested(obj)
            is = obj.is_tested_;
        end
        function flog = get.logger(obj)
            flog = obj.logger_;
        end
        %------------------------------------------------------
        function set.is_deployed(obj,val)
            obj.is_deployed_=val;
        end
        function set.is_tested(obj,val)
            obj.is_tested_=val;
        end
        function set.logger(obj,fun)
            if ~isa(fun, 'function_handle')
                error('MPI_STATE:invalid_argument',...
                    ' value assigned to a logger function has to be a function handle')
            end
            obj.logger_=fun;
        end
        %-------------------------------------------------------
        function set.check_cancelled(obj,fun)
            if ~isa(fun, 'function_handle')
                error('MPI_STATE:invalid_argument',...
                    ' value assigned to a check_cancelled function has to be a function handle')
            end
            obj.check_cancelled_=fun;
        end
        function check_cancellation(obj)
            % method runs check_cancelled function to verify if MPI
            % calculations were cancelled.
            if ~isempty(obj.check_cancelled_)
                obj.check_cancelled_();
            end
        end
        function fw = get.mpi_framework(obj)
            fw = obj.mpi_framework_;
        end
        function set.mpi_framework(obj,val)
            if ~isa(val,'iMessagesFramework')
                error('MPI_STATE:invalid_argument',...
                    'input for MPI framework field should be instance of iMessageFramework class');
            end
            obj.mpi_framework_ = val;
        end
        %-------------------------------------------------------
        function setattr(obj,varargin)
            par=varargin(1:2:nargin-1);
            val=varargin(2:2:nargin-1);
            if ~any(ismember(par,obj.field_names_))
                error('MPI_STATE:invalid_argument',' Field %s is not the class attribute',par{:});
            else
                if iscell(par)
                    for i=1:numel(par)
                        obj.([par{i},'_'])=val{i};
                    end
                else
                    obj.([par,'_'])=val;
                end
            end
        end
        %-----------------------------------------------------------------
        
        function do_logging(obj,step,n_steps,ttf,additional_info)
            % do logging if appropriate logging function has been set-up
            % Inputs:
            % step    -- current step job is doing
            % n_steps -- total number of steps to do
            % ttf     -- time interval between subsequent calls to logging
            %            function used as basis to estimate time for MPI job
            %            to fail according to time-out.
            %            If empty, the function will try to estimate this
            %            'time to fail' interval itself.
            % additional_info -- some string to display in logging
            %            framework
            %
            % Sends LogMessage to the framework
            %
            % identify time interval between subsequent calls to this
            % function if such interval have not been provided
            if ~isempty(obj.logger_)
                if isempty(ttf)
                    if isempty(obj.start_time_)
                        obj.start_time_ = tic;
                        ttf = 0; % 0 interval means infinite waiting time between calls
                        obj.prev_time_interval_ = 0;
                    else
                        ttf = toc(obj.start_time_);
                        if step > 0
                            ttf = ttf/step;
                        end
                    end
                end
                if ttf ~= obj.prev_time_interval_
                    if ttf == 0
                        % 0 time resets timing preferences
                    else
                        % let's decrease time gradually to deal with
                        % blips in performance
                        ttf = 0.5*(ttf+obj.prev_time_interval_);
                        obj.prev_time_interval_ = ttf;
                    end
                else
                    obj.prev_time_interval_ = ttf;
                end
                % log
                obj.logger_(step,n_steps,ttf,additional_info);
            end
        end
        
        function set(obj,varargin)
            % functional assignment of class parameter with list of key-value
            % pairs
            % Usage:
            % mis = MPI_State;
            % set(mis,key,value,[key,value,....])
            % where mis is the instance of MPI state object and the key-value
            % pairs should be a list of valid properties of the class with
            % their correspondent values to set.
            %
            if rem(numel(varargin),2)>0
                error('MPI_STATE:invalid_argument',...
                    ' set(MPI_State,key,value,[key,value] should have even number of key-value pairs')
            end
            for i=1:2:numel(varargin)
                obj.(varargin{i}) = varargin{i+1};
            end
        end
        
    end
    
    
end

