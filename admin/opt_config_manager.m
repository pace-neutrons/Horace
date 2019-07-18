classdef opt_config_manager
    %The class keeps the list of optimal horace/herbert configurations
    %for different types of the computer and return such configuration
    %on request.
    %
    properties(Dependent,Access=public)
        % what type (out of known types) this pc belongs to. Usually is
        % calculated automatically but can be set up manually for class
        % testing purposes.
        this_pc_type;
        % The folder where optimal class configurations are stored.
        % Normally it is the class folder but may be changed for testing
        % purposes
        config_info_folder;
        % the name of the file, containing the configuration
        config_filename;
    end
    
    
    properties(Access=private)
        test_mode_ = false;
        config_info_folder_;
        this_pc_type_;
        config_filename_  = 'OptimalConfig.xml'
        current_config_ = [];
    end
    properties(Constant,Access=private)
        % the configurations, which may be optimized for a particular pc so
        % should be stored
        known_configs_ = {'herbert_config','hor_config','hpc_config','parallel_config'}
        % different pc types, one may optimize Horace/Herbert for. The
        % order of the types is harwritten in the find_pc_type_ function,
        % so should not be changed without changning find_pc_type_.
        known_pc_types_ = {'win_small','win_large','a_mac',...
            'unix_small','unix_large',...
            'idaaas_small','idaaas_large'};
        
    end
    
    methods
        function obj = opt_config_manager()
            %
            obj.config_info_folder_ = fileparts(mfilename('fullpath'));
            obj.this_pc_type_ = find_pc_type(obj);
            
        end
        function types = get_known_pc_types(obj)
            types = obj.known_pc_types_;
        end
        function pc_type = get.this_pc_type(obj)
            pc_type = obj.this_pc_type_;
        end
        function obj = set.this_pc_type(obj,val)
            % explisitly setting pc type for testing purposes.
            if isnumeric(val)
                n_types = numel(obj.known_pc_types_);
                if val>0 && val<=n_types
                    pc_type = obj.known_pc_types_{val};
                else
                    print_help(obj);
                    error('OPT_CONFIG_MANAGER:invalid_argument',...
                        'Known pc type should be a number from the list above and the input is: %d',val);
                end
            elseif ischar(val)
                is_it = ismember(obj.known_pc_types_,val);
                if sum(is_it) == 1
                    pc_type  = obj.known_pc_types_(is_it);
                else
                    print_help(obj);
                    error('OPT_CONFIG_MANAGER:invalid_argument',...
                        'Known pc type should be a string from the list above and the input is: %s',val);
                end
            else
                print_help(obj);
                error('OPT_CONFIG_MANAGER:invalid_argument',...
                    'The pc type may be either the name of the pc type from the list above or the type number in this list');
            end
            obj.this_pc_type_ = pc_type;
        end
        
        function save_configurations(obj)
            % assuming the current configuration is the optimal one, save
            % it in configuration file for further usage.
            save_configurations_(obj);
        end
        
    end
    methods(Access=private)
        function print_help(obj)
            types = obj.known_pc_types_;
            fprintf('**** Known pc types are:\n');
            for i=1:numel(types)
                fprintf('    :%d  : %s\n',i,types{i});
            end
            
        end
    end
    methods(Static)
        function pc_type = find_pc_type()
            % analyze pc parameters and return pc type which describes
            % these parameters
            pc_type = find_pc_type_();
        end
        
    end
end

