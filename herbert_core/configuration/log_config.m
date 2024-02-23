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
        %------------------------------------------------------------------
        % PAGEOP SPECIFIC SETTINGS
        % store logging ratios for various algorithms which ise apply_op;
        recompute_bins_split_ratio;
        apply_split_ratio;
        sqw_binary_double_split_ratio;
        sqw_binary_img_split_ratio;
        sqw_binary_sqw_split_ratio;
        cat_pix_split_ratio;
        coord_calc_split_ratio;
        func_eval_split_ratio;
        join_sqw_split_ratio;
        mask_split_ratio;
        noisify_split_ratio;
        section_split_ratio;
        sigvar_set_split_ratio;
        split_sqw_split_ratio;
        sqw_eval_split_ratio;
        unary_op_split_ratio;
    end
    properties(Hidden)
        % helper property which helps organize consisten logging in
        % apply_op routine. It set to true when log algorithm have
        % printed alive-log dot and to false when other logging have been 
        % performed. Introduced to simplify log prints in transitions
        % between different parts of apply_op routine
        dot_printed = false;
    end

    properties(Access=protected, Hidden=true)
        info_log_print_time_ = 30 % normally info log should be printed
        %                         % every 30 secodd

        recompute_bins_split_ratio_    = 1;
        apply_split_ratio_             = 1;
        sqw_binary_double_split_ratio_ = 1;
        sqw_binary_img_split_ratio_    = 1;
        sqw_binary_sqw_split_ratio_    = 1;
        cat_pix_split_ratio_           = 1;
        coord_calc_split_ratio_        = 1;
        func_eval_split_ratio_         = 1;
        join_sqw_split_ratio_          = 1;
        mask_split_ratio_              = 1;
        noisify_split_ratio_           = 1;
        section_split_ratio_           = 1;
        sigvar_set_split_ratio_        = 1;
        split_sqw_split_ratio_         = 1;
        sqw_eval_split_ratio_          = 1;
        unary_op_split_ratio_          = 1;
    end
    properties(Access=private)
        % The variable used to identify how often log should be performed
        % to
        info_log_split_ratio_ = 1;
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
            split_ratio = obj.info_log_print_time/time_per_step;
            obj.info_log_split_ratio_ = ...
                log_config.check_integer_larger_then_one( ...
                split_ratio,'info_log_split_ratio',false);
        end

        %-----------------------------------------------------------------
    end
    %======================================================================
    % GETTETS, SETTERS
    methods
        function mcs = get.info_log_split_ratio(obj)
            mcs = obj.info_log_split_ratio_;
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
        %==================================================================
        function rat = get.recompute_bins_split_ratio(~)
            rat = config_store.instance().get_value('log_config','recompute_bins_split_ratio');
        end
        function obj = set.recompute_bins_split_ratio(obj,val)
            val = log_config.check_integer_larger_then_one(val,'recompute_bins_split_ratio',true);
            config_store.instance().store_config(obj,'recompute_bins_split_ratio',val);
        end
        %
        function rat = get.apply_split_ratio(~)
            rat = config_store.instance().get_value('log_config','apply_split_ratio');
        end
        function obj = set.apply_split_ratio(obj,val)
            val = log_config.check_integer_larger_then_one(val,'apply_split_ratio',true);
            config_store.instance().store_config(obj,'apply_split_ratio',val(1));
        end
        %
        function rat = get.sqw_binary_double_split_ratio(~)
            rat = config_store.instance().get_value('log_config','sqw_binary_double_split_ratio');
        end
        function obj = set.sqw_binary_double_split_ratio(obj,val)
            val = log_config.check_integer_larger_then_one(val,'sqw_binary_double_split_ratio',true);
            config_store.instance().store_config(obj,'sqw_binary_double_split_ratio',val);
        end
        %
        function rat = get.sqw_binary_img_split_ratio(~)
            rat = config_store.instance().get_value('log_config','sqw_binary_img_split_ratio');
        end
        function obj = set.sqw_binary_img_split_ratio(obj,val)
            val = log_config.check_integer_larger_then_one(val,'sqw_binary_img_split_ratio',true);
            config_store.instance().store_config(obj,'sqw_binary_img_split_ratio',val);
        end
        %
        function rat = get.sqw_binary_sqw_split_ratio(~)
            rat = config_store.instance().get_value('log_config','sqw_binary_sqw_split_ratio');
        end
        function obj = set.sqw_binary_sqw_split_ratio(obj,val)
            val = log_config.check_integer_larger_then_one(val,'sqw_binary_sqw_split_ratio',true);
            config_store.instance().store_config(obj,'sqw_binary_sqw_split_ratio',val);
        end
        %
        function rat = get.cat_pix_split_ratio(~)
            rat = config_store.instance().get_value('log_config','cat_pix_split_ratio');
        end
        function obj = set.cat_pix_split_ratio(obj,val)
            val = log_config.check_integer_larger_then_one(val,'cat_pix_split_ratio',true);
            config_store.instance().store_config(obj,'cat_pix_split_ratio',val);
        end
        %
        function rat = get.coord_calc_split_ratio(~)
            rat = config_store.instance().get_value('log_config','coord_calc_split_ratio');
        end
        function obj = set.coord_calc_split_ratio(obj,val)
            val = log_config.check_integer_larger_then_one(val,'coord_calc_split_ratio',true);
            config_store.instance().store_config(obj,'coord_calc_split_ratio',val);
        end
        %
        function rat = get.func_eval_split_ratio(~)
            rat = config_store.instance().get_value('log_config','func_eval_split_ratio');
        end
        function obj = set.func_eval_split_ratio(obj,val)
            val = log_config.check_integer_larger_then_one(val,'func_eval_split_ratio',true);
            config_store.instance().store_config(obj,'func_eval_split_ratio',val);
        end
        %
        function rat = get.join_sqw_split_ratio(~)
            rat = config_store.instance().get_value('log_config','join_sqw_split_ratio');
        end
        function obj = set.join_sqw_split_ratio(obj,val)
            val = log_config.check_integer_larger_then_one(val,'join_sqw_split_ratio',true);
            config_store.instance().store_config(obj,'join_sqw_split_ratio',val);
        end
        %
        function rat = get.mask_split_ratio(~)
            rat = config_store.instance().get_value('log_config','mask_split_ratio');
        end
        function obj = set.mask_split_ratio(obj,val)
            val = log_config.check_integer_larger_then_one(val,'mask_split_ratio',true);
            config_store.instance().store_config(obj,'mask_split_ratio',val);
        end
        %
        function rat = get.noisify_split_ratio(~)
            rat = config_store.instance().get_value('log_config','noisify_split_ratio');
        end
        function obj = set.noisify_split_ratio(obj,val)
            val = log_config.check_integer_larger_then_one(val,'noisify_split_ratio',true);
            config_store.instance().store_config(obj,'noisify_split_ratio',val);
        end
        %
        function rat = get.section_split_ratio(~)
            rat = config_store.instance().get_value('log_config','section_split_ratio');
        end
        function obj = set.section_split_ratio(obj,val)
            val = log_config.check_integer_larger_then_one(val,'section_split_ratio',true);
            config_store.instance().store_config(obj,'section_split_ratio',val);
        end
        %
        function rat = get.sigvar_set_split_ratio(~)
            rat = config_store.instance().get_value('log_config','sigvar_set_split_ratio');
        end
        function obj = set.sigvar_set_split_ratio(obj,val)
            val = log_config.check_integer_larger_then_one(val,'sigvar_set_split_ratio',true);
            config_store.instance().store_config(obj,'sigvar_set_split_ratio',val);
        end
        %
        function rat = get.split_sqw_split_ratio(~)
            rat = config_store.instance().get_value('log_config','split_sqw_split_ratio');
        end
        function obj = set.split_sqw_split_ratio(obj,val)
            val = log_config.check_integer_larger_then_one(val,'split_sqw_split_ratio',true);
            config_store.instance().store_config(obj,'split_sqw_split_ratio',val);
        end
        %
        function rat = get.sqw_eval_split_ratio(~)
            rat = config_store.instance().get_value('log_config','sqw_eval_split_ratio');
        end
        function obj = set.sqw_eval_split_ratio(obj,val)
            val = log_config.check_integer_larger_then_one(val,'sqw_eval_split_ratio',true);
            config_store.instance().store_config(obj,'sqw_eval_split_ratio',val);
        end
        %
        function rat = get.unary_op_split_ratio(~)
            rat = config_store.instance().get_value('log_config','unary_op_split_ratio');
        end
        function obj = set.unary_op_split_ratio(obj,val)
            val = log_config.check_integer_larger_then_one(val,'unary_op_split_ratio',true);
            config_store.instance().store_config(obj,'unary_op_split_ratio',val);
        end
    end
    methods(Static,Access=private)
        function val = check_integer_larger_then_one(val,method_name,warn_user)
            if ~isnumeric(val)
                error('HERBERT:Log_config:invalid_argument', ...
                    'Only numeric value allowed for %s. Provided: %s', ...
                    method_name,class(val))
            end
            if numel(val)>1
                error('HERBERT:Log_config:invalid_argument', ...
                    'Input for property %s can be scalar only. Attempt to set value with %d elements', ...
                    method_name,numel(val));
            end
            if val < 1 && warn_user
                warning('LOG_CONFIG:setting_log_split_ratio',[...
                    '*** Attempt to set %s to be smaller then 1\n', ...
                    '    Changed to be 1. Think about decreasing calculations chunk size\n',...
                    '    as time of calculating single chunk exceeds info_log_print_time'], ...
                    method_name);
            end
            val  = max(1,round(val));
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
                'recompute_bins_split_ratio',...
                'apply_split_ratio',...
                'sqw_binary_double_split_ratio',...
                'sqw_binary_img_split_ratio',...
                'sqw_binary_sqw_split_ratio',...
                'cat_pix_split_ratio',...
                'coord_calc_split_ratio',...
                'func_eval_split_ratio',...
                'join_sqw_split_ratio',...
                'mask_split_ratio',...
                'noisify_split_ratio',...
                'section_split_ratio',...
                'sigvar_set_split_ratio',...
                'split_sqw_split_ratio',...
                'sqw_eval_split_ratio',...
                'unary_op_split_ratio'...
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
