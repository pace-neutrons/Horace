classdef ClusterWrapper
    % The class-wrapper containing common code for any Matlab cluster,
    % and job progress logging operations supported by Herbert
    %
    % $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)
    %
    %----------------------------------------------------------------------
    properties(Dependent)   %
        % the property identifies that wrapper received the message that
        % the cluster status have changed
        status_changed;
        % the current cluster status, usually defined by status message
        status;
        % The string which describes the current status
        log_value
        % The accessor for mess_exchange_framework job_id if mess exchange
        % framework is defined
        job_id
        % number of workers in the cluster
        n_workers;
    end
    properties(Access = protected)
        n_workers_   = 0;
        mess_exchange_ =[];
        %
        status_changed_ = false;
        current_status_ = [];
        prev_status_=[];
        log_value_ = '';
        
        %
        display_results_count_ = 0;
        LOG_MESSAGE_WRAP_LENGTH =10;
    end
    properties(Constant,Access = protected)
        LOG_MESSAGE_LENGHT=40;
    end
    
    methods
        function obj = ClusterWrapper(n_workers,mess_exchange_framework)
            % Constructor, which initiates wrapper
            %
            obj.mess_exchange_ = mess_exchange_framework;
            obj.n_workers_   = n_workers;
            
            
            obj.LOG_MESSAGE_WRAP_LENGTH = ...
                numel(mess_exchange_framework.job_id)+numel('Job : ')+numel(' :');
        end
        %
        function obj = init_cluster(obj,je_init_message,task_init_mess)
            % send initialization information to each worker in the cluster
            % and receive responce informing that the job has started
            
            obj = init_cluster_(obj,je_init_message,task_init_mess);
        end
        %
        function [completed, obj] = check_progress(obj,varargin)
            % Check the job progress verifying and receiving all messages,
            % sent from worker N1
            %
            % usage:
            %>> [completed, obj] = check_progress(obj)
            %>> [completed, obj] = check_progress(obj,status_message)
            %
            % The first form checks and receives all messages addressed to
            % job dispatched node where the second form accepts and
            % verifies status message, received by other means
            [completed,obj] = check_progress_(obj,varargin{:});
        end
        function obj = display_progress(obj,varargin)
            % report job progress using internal state of the cluster
            % derived by executing check_progress method
            %
            options = {'-force_display'};
            [ok,mess,force_display,argi] = parse_char_options(varargin,options);
            if ~ok;error('CLUSTER_WRAPPER:invalid_argument',mess); end
            
            obj = obj.generate_log(argi{:});
            if force_display
                display_log = true;
            else
                hc = herbert_config;
                log_level = hc.log_level;
                if log_level > 0
                    display_log = true;
                else
                    display_log = false;
                end
            end
            if display_log
                fprintf(obj.log_value);
            end
            
        end
        function obj=finalize_all(obj)
            if ~isempty(obj.mess_exchange_)
                obj.mess_exchange_.finalize_all();
                obj.mess_exchange_ = [];
            end
        end
        %------------------------------------------------------------------
        function isit = get.status_changed(obj)
            isit = obj.status_changed_;
        end
        function log = get.log_value(obj)
            log = obj.log_value_;
        end
        function id = get.job_id(obj)
            if isempty(obj.mess_exchange_)
                id = 'undefined';
            else
                id = obj.mess_exchange_.job_id();
            end
        end
        function nw = get.n_workers(obj)
            nw = obj.n_workers_;
        end        
        %
        function isit = get.status(obj)
            isit = obj.current_status_;
        end
        function obj = set.status(obj,mess)
            if isa(mess,'aMessage')
                stat_mess = mess;
            elseif ischar(mess)
                stat_mess = aMessage(mess);
            else
                error('CLUSTER_WRAPPER:invalid_argument',...
                    'status is defined by aMessage class only or a message name')
            end
            obj.prev_status_ = obj.current_status_;
            obj.current_status_ = stat_mess;
            if obj.prev_status_ ~= obj.current_status_
                obj.status_changed_ = true;
            end
        end
    end
    methods(Access=protected)
        function obj = generate_log(obj,varargin)
            % set log message from input parameters and the data, retrieved
            % by check_progress method
            obj = generate_log_(obj,varargin{:});
        end
    end
end

