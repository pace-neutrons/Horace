classdef parallel_config<config_base
    % The class to configure Herbert parlallel framework
    %
    % To see the list of current configuration option values:
    %   >> parallel_config
    %
    % To set values:
    %   >> set(parallel_config,'name1',val1,'name2',val2,...)
    % or just
    %   >>hc = parallel_config();
    %   >>hc.name1 = val1;
    %
    % To fetch values:
    %   >> [val1,val2,...]=get(parallel_config,'name1','name2',...)
    % or just
    %   >>val1 = parallel_config.name1;
    
    %
    % Fields are:
    % -----------
    %   parallel_framework  -
    %
    %
    % Type:
    %>>parallel_config  to see the list of current configuration option values.
    %
    %
    % $Revision: 630 $ ($Date: 2017-10-06 18:43:58 +0100 (Fri, 06 Oct 2017) $)
    %
    
    properties(Dependent)
        parallel_framework;
    end
    %
    properties(Constant,Access=private)
        saved_properties_list_={'parallel_framework'};
    end
    properties(Access=private)
        % these values provide defaults for the properties above
        parallel_framework_   = 'matlab';
    end
    methods
        function this = parallel_config()
            % constructor
            this=this@config_base(mfilename('class'));
        end
        %-----------------------------------------------------------------
        % overloaded getters
        function frmw =get.parallel_framework(obj)
            frmw = get_or_restore_field(obj,'parallel_framework');
        end
        %-----------------------------------------------------------------
        % overloaded setters
        function obj =set.parallel_framework(obj,val)
            % Set up MPI framework to use. Availible options are:
            % matlab or parpool.
            %
            opt = {'matlab','parpool'};
            [ok,err,is_matlab,is_partool,rest] = parse_char_options({val},opt);
            if ~isempty(rest)
                error('PARALLEL_CONFIG:invalid_argument',...
                    sprinft('Unknown option %s',val));
            end
            if ~ok
                error('PARALLEL_CONFIG:invalid_argument',err);
            end
            if is_matlab
                config_store.instance().store_config(...
                    obj,'parallel_framework','matlab');
                return;
            end
            if is_partool
                check_and_set_parpool_framework_(obj);
            end
        end
        function controller = get_controller(obj)
            % return the appropriate job controller
            fram = obj.parallel_framework;
            switch(fram)
                case('matlab')
                    controller = JavaTaskWrapper();
                case('parpool')
                    controller = ParpoolTaskWrapper();
                otherwise
                    error('PARALLEL_CONFIG:runtime_error',...
                        'Get unknown controller: %s',fram);
            end
        end
        %------------------------------------------------------------------
        % ABSTACT INTERFACE DEFINED
        %------------------------------------------------------------------
        function fields = get_storage_field_names(this)
            % helper function returns the list of the name of the structure,
            % get_data_to_store returns
            fields = this.saved_properties_list_;
        end
        function value = get_internal_field(this,field_name)
            % method gets internal field value bypassing standard get/set
            % methods interface
            value = this.([field_name,'_']);
        end
    end
end

