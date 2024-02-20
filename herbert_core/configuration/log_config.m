classdef log_config < config_base
    % The class containing information on how often a page_op should be
    % logged to provide reasonable user experience
    %
    % To see the list of current configuration option values:
    %   >> log_config
    %
    % To set values:
    %   >> lc = log_config ();
    %   >> lc.name1=val1;
    % or
    %   >> set(log_config,'name1',val1,'name2',val2,...)
    %
    %
    % To fetch values:
    % >> val1 = log_config.name1;
    %or
    % >>[val1,val2,...]=get(log_config,'name1','name2',...)
    %
    %
    % log_config properties are:
    % -----------
    properties(Dependent)
        % GENERAL PROPERTIES
        % how often (in sec) progess info log should be printed when
        % operation is performed.
        info_log_print_time;
        % this value define automatic split step, calculated during logging
        % from info_log_print_time ant time spent on doing every step of
        % the algorithm.
        info_log_split_ratio;
    end

    properties(Access=protected, Hidden=true)
        info_log_print_time_ = 30 % normally info log should be printed
        %                         % every 30 secodd
    end
    properties(Access=private)
        % The variable used to identify how often log should be performed
        % to
        info_log_split_ratio_ = [];
        log_time_holder_;
    end

    methods
        function obj=log_config()
            obj=obj@config_base(mfilename('class'));
            obj.warn_if_missing_config = false;
        end
        %-----------------------------------------------------------------
        function obj = init_adaptive_logging(obj)
            % initialize adaptive logging procedure
            obj.log_time_holder_ = tic();
        end
        function [obj,pass_time] = adapt_logging(obj,n_step)
            % initialize adaptive logging procedure
            % Inputs:
            % obj    -- initialized instance of log_config class with timer
            %           started at the beginning of the logging loop
            % n_step -- number of step perfomed from the start of the
            %           logging loop
            % Output:
            % obj    -- instance of log_config class containing modified
            %           log_split_ratio
            % pass_time
            %        -- time passed from the time when
            %           init_adaptive_logging was called to the call of
            %           this function.
            pass_time = toc(obj.log_time_holder_);
            time_per_step = pass_time/n_step;
            obj.info_log_split_ratio = round(obj.info_log_print_time/time_per_step);
        end

        %-----------------------------------------------------------------
    end
    %======================================================================
    % GETTETS, SETTERS
    methods
        function mcs = get.info_log_split_ratio(obj)
            if isempty(obj.info_log_split_ratio_)
                mcs = config_store.instance().get_value('hor_config','fb_scale_factor');
            else
                mcs = obj.info_log_split_ratio_;
            end
        end
        function obj = set.info_log_split_ratio(obj,val)
            obj.info_log_split_ratio_ = log_config.check_larger_then_one(val,'info_log_split_ratio',false);
        end
        %
        function mcs = get.info_log_print_time(obj)
            mcs = get_or_restore_field(obj,'info_log_print_time');
        end
        function obj = set.info_log_print_time(obj,val)
            if val<1 % no point of making it smaller then 1 sec
                val = 1;
            end
            config_store.instance().store_config(obj,'info_log_print_time',val);
        end
    end
    methods(Static,Access=private)
        function val = check_larger_then_one(val,method_name,warn_user)
            if val < 1
                if warn_user
                    warning('LOG_CONFIG:finalize_alignment_alive_split_ratio',...
                        [' Attempt to set logging %s logging ratio to be less then 1\n', ...
                        'This is impossible so 1 is selected. Think about decreasing calculations chunk size'], ...
                        method_name);
                end
                val  = 1;
            end
        end
    end
    %======================================================================
    % ABSTACT INTERFACE DEFINED
    %======================================================================
    methods
        function fields = get_storage_field_names(~)
            % helper function returns the list of the public names of the fields,
            % which should be saved
            fields = {...
                'info_log_print_time',  ...
                'info_log_split_ratio', ...
                };
        end

        function value = get_default_value(obj,field_name)
            % method gets internal field value bypassing standard get/set
            % methods interface.
            % Relies on assumption, that each public
            % field has a private field with name different by underscore
            %
            % implemented here to get access to protected properties values
            value = obj.([field_name,'_']);
        end
    end

end
