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
        % The convenience method, defining the number of the current pc
        % configuration in the list of all configurations
        pc_config_num
    end
    
    
    properties(Access=private)
        test_mode_ = false;
        config_info_folder_;
        this_pc_type_;
        config_filename_  = 'OptimalConfigInfo.xml'
        current_config_ = [];
    end
    properties(Access=private)
        % the configurations, which may be optimized for a particular pc so
        % should be stored
        known_configs_ = {'herbert_config','hor_config','hpc_config','parallel_config'}
        % different pc types, one may optimize Horace/Herbert for. The
        % order of the types is harwritten in the find_comp_type function,
        % so should not be changed without changning find_comp_type.
        known_pc_types_ = {'win_small','win_large','a_mac',...
            'unix_small','unix_large',...
            'idaaas_small','idaaas_large'};
        % amount of memory (in Gb) pesumed to be necessary for a single
        % parallel worker.
        mem_size_per_worker_ = 16;
    end
    
    methods
        function obj = opt_config_manager()
            %
            obj.config_info_folder_ = fileparts(mfilename('fullpath'));
            obj.this_pc_type_ = find_comp_type_(obj);
            if isempty(which('horace_init'))
                obj.known_configs_ = {'herbert_config','parallel_config'};
            end
            
        end
        function types = get_known_pc_types(obj)
            types = obj.known_pc_types_;
        end
        function fn = get.config_filename(obj)
            fn = obj.config_filename_;
        end
        %
        function fldr=get.config_info_folder(obj)
            fldr = obj.config_info_folder_;
        end
        function obj=set.config_info_folder(obj,val)
            % set folder containign config information.
            %
            % should be used for testing purposes only.
            obj.config_info_folder_ = val;
        end
        %
        function pc_type = get.this_pc_type(obj)
            pc_type = obj.this_pc_type_;
        end
        %
        function obj = set.this_pc_type(obj,val)
            % explisitly setting pc type for testing or debugging purposes.
            %
            % the type can be set by name (from the list of the names
            % specified in the list definition) or by the number of the pc
            % type in the same list
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
                    pc_type  = obj.known_pc_types_{is_it};
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
        %
        function num = get.pc_config_num(obj)
            % return the number of the
            cur_type = obj.this_pc_type;
            num = find(ismember(obj.known_pc_types_,cur_type),1);
        end
        %------------------------------------------------------------------
        function save_configurations(obj,varargin)
            % assuming the current configuration is the optimal one, save
            % it in configuration file for further usage.
            % Usage:
            % obj.save_configurations([info]);
            % where:
            % info -- optional information, providing additional
            %         information about the configuration of the given type
            %         of the computer;
            save_configurations_(obj,varargin{:});
        end
        function conf = load_configuration(obj,varargin)
            % method loads the previous configuration, which
            % stored as optimal for this computer.
            %
            % '-set_config' if option is present, method also configures
            %               Horace and Herbert using the configuration,
            %               stored as optimal for this computer.
            % '-change_only_default' if this option is present, the method
            %       configured only the configurations, which values are
            %       currently set to default not overwritng existign user
            %       settings
            % '-force_save' if this option is present, the
            %       configuration, loaded from the defaults is stored in
            %       configuration file for future use on this computer
            %       regardless of the fact if this configuration is
            %       different from a default configuration or not.
            %
            % Returns the structure, containing loaded configurations.
            %
            [ok,mess,set_config,set_def_only,force_save] = parse_char_options(varargin,...
                {'-set_config','-change_only_default','-force_save'});
            if ~ok; error('OPT_CONFIG_MANAGER:invalid_argument',mess);
            end
            conf = load_configuration_(obj,set_config,set_def_only,force_save);
        end
        function [pc_type,nproc,mem_size] = find_comp_type(obj)
            % analyze pc parameters (memory, number of processors etc.)
            % and return pc type.
            %
            % A pc type is a string, describing the computer from point of
            % view of using it for high performance communications.
            %
            % Returns:
            % pc_type -- the sting containing the type of the pc. The type
            %            is selected from the list of known types and
            %            used as the key to the list of configurations,
            %            find to be optimal for each pc type.
            % nproc   -- number of parallel processes (matlab workers) can
            %            be used in parallel (MPI) computations.
            % mem_size-- The size of the physical memory in bytes,
            %

            [pc_type,nproc,mem_size] = find_comp_type_(obj);
        end
        
        
    end
    methods(Access=private)
        function print_help(obj)
            ll = get(herbert_config,'log_level');
            if ll>0
                types = obj.known_pc_types_;
                fprintf('**** Known pc types are:\n');
                for i=1:numel(types)
                    fprintf('    :%d  : %s\n',i,types{i});
                end
            end
            
        end
    end
end

