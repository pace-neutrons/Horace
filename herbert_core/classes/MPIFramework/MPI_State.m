classdef MPI_State<handle
    % Helper class, to identify status of Matlab job, namely if current
    % Matlab session is independent session or is deployed by Herbert MPI
    % framework, and to help to deploy methods, which would depend on such
    % status, including access to messages framework to exchange messages
    % between various tasks.
    %
    % 'MPI-deployed' state is set up in parallel_worker functiom, which is
    % executed by all parallel jobs.
    % The state should be checked by the client,
    % inheriting from JobExecutor within the loop executed within do_job method.
    %
    % Implemented as classical singleton.

    properties(Dependent)
        % report if the Matlab session is deployed on a remote worker
        is_deployed
        % logger function to use to log activities of an mpi worker
        logger
        % the function to run verifying if job has been cancelled
        check_cancelled;
        % method helps to identify that the framework is tested and to
        % disable some framework capabilities, which should be used in this
        % situation
        is_tested
        % current active message exchange framework for advanced messages
        % exchange.
        mpi_framework;
        % index of the running lab
        labIndex;
        % Total number of labs in parallel pool.
        numLabs;
        % the property, used to assign handle for logging the progress of
        % MPI job during debugging. To be asigned to file handle of a
        % log file, specific for the specific worker and kept here to be
        % available from any place in a mpi part of the program. The log
        % file is located in tempdir and named worker_log_XXXXXXXXXX.log
        % where XXXXXXXXXX is the selection of 10 random ASCII characters
        % selected from capital letters.
        debug_log_handle
        % property returning true if debug_log_handle is initialized and
        % can be used
        trace_log_enabled
    end
    properties(Access=protected)
        is_deployed_=false;
        logger_ = [];
        check_cancelled_=[];
        is_tested_ = false;
        % variables, used to identify time intervals between subsequent
        % calls to logging function
        start_time_=[];
        time_per_step_= 0;
        mpi_framework_ = [];
        debug_log_handle_ = [];
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
        function  li = get.labIndex(obj)
            if isempty(obj.mpi_framework_)
                li = 0;
            else
                li = obj.mpi_framework_.labIndex;
            end
        end
        function  nl = get.numLabs(obj)
            if isempty(obj.mpi_framework_)
                nl = 0;
            else
                nl = obj.mpi_framework_.numLabs;
            end
        end
        function fh = get.debug_log_handle(obj)
            % opend debug_log_file on the first access
            if isempty(obj.debug_log_handle_)
                seed = uint64(feature('getpid'));
                rng(seed);
                fn = ['worker_log_',char(randi([65 90],1,10)),'.log'];
                obj.debug_log_handle_ = fopen(fullfile(tempdir,fn),'w');
            end
            fh = obj.debug_log_handle_;
        end
        function is = get.trace_log_enabled(obj)
            is  = false;
            if ~isempty(obj.debug_log_handle_) && obj.debug_log_handle_>1
                fn = fopen(obj.debug_log_handle_);
                if ~isempty(fn)
                    is = true;
                end
            end
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
            %clear start time as setting this to empty resets timers
            obj.start_time_ = [];
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

        function do_logging(obj,step,n_steps,tps,additional_info)
            % do logging if appropriate logging function has been set-up
            % Inputs:
            % step    -- current step job is doing
            % n_steps -- total number of steps to do
            % tps     -- time interval between subsequent calls to logging
            %            function used as basis to estimate time, the job
            %            will be running.
            % additional_info -- some string to display in logging
            %            framework
            %
            % Sends LogMessage to the framework
            %
            % identify time interval between subsequent calls to this
            % function if such interval have not been provided
            if ~isempty(obj.logger_)
                if ~exist('tps', 'var')
                    tps = [];
                end
                if isempty(tps)
                    if isempty(obj.start_time_)
                        obj.start_time_ = tic;
                        tps = 0; % 0 interval means infinite waiting time between calls
                        obj.time_per_step_ = 0;
                    else
                        tps = toc(obj.start_time_);
                        if step > 0
                            tps = tps/step;
                        end
                    end
                end
                obj.time_per_step_ = tps;
                if ~exist('additional_info', 'var')
                    additional_info = [];
                end
                %
                obj.logger_(step,n_steps,tps,additional_info);
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
        function delete(obj)
            if ~isempty(obj.debug_log_handle_)
                fclose(obj.debug_log_handle_);
            end
            obj.is_deployed_=false;
            obj.logger_ = [];
            obj.check_cancelled_=[];
            obj.is_tested_ = false;
            obj.start_time_=[];
            obj.time_per_step_= 0;
            obj.mpi_framework_ = [];
            obj.debug_log_handle_ = [];
        end
    end
end
