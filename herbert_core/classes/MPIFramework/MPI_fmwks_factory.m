classdef MPI_fmwks_factory<handle
    % The class, providing the subscription factory for
    % various type of MPI frameworks, available to users.
    %
    % Any new type of framework should subscribe to this factory.
    %
    % Implemented as classical singleton.
    
    properties(Dependent)
        % current active message exchange framework for advanced messages
        % exchange.
        mpi_framework;
        % Information method returning the list of the parallel frameworks,
        % known to Herbert. You can not add or change a framework
        % using this method, The framework has to be defined and subscribed
        % via the algorithms factory.
        known_frameworks
        %
    end
    properties(Access=protected)
        mpi_framework_ = ''
    end
    properties(Constant, Access=protected)
        % Subscription factory:
        % the list of the known framework names.
        known_frmwks_names_ = {'herbert','parpool','mpiexec_mpi'};
        % The map to exisiting parallel frameworks clusters
        known_frameworks_ = containers.Map(parallel_config.known_frmwks_names_,...
            {ClusterHerbert(),ClusterParpoolWrapper(),ClusterMPI()});
        % the map of the framework indexes
        frmwk_ids_ = containers.Map(parallel_config.known_frmwks_names_,...
            {1,2,3});
        
    end
    %----------------------------------------------------------------------
    methods(Access=private)
        function obj=MPI_fmwks_factory()
        end
    end
    %----------------------------------------------------------------------
    methods(Static)
        function obj = instance(varargin)
            persistent obj_state;
            if isempty(obj_state)
                obj_state = MPI_fmwks_factory();
            end
            obj=obj_state;
        end
    end
    %----------------------------------------------------------------------
    methods
        %------------------------------------------------------
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
        function cfg = get_all_configs(obj,fram)
            % return all known configurations for the framework with the
            % name, provided as input or used as default framework if
            % the name is not provided.
            if ~exist('fram','var')
                fram = config_store.instance().get_config_field('parallel_config','parallel_framework');
            end
            if strcmpi(fram,'n\a')
                cfg = 'n\a';
                return;
            end
            controller = obj.known_frameworks_(fram);
            cfg = controller.get_cluster_configs_available();
        end
        
        function obj=select_framework(obj,val)
            % Set up MPI framework to use. Available options are:
            % h[erbert], p[arpool] or m[pi_cluster]
            % (can be defined by single symbol) or by a framework number
            % in the list of frameworks
            %
            opt = obj.known_frmwks_names_;
            the_name = parallel_config.select_option(opt,val);
            theCluster = obj.known_frameworks_(the_name);
            % will throw PARALLEL_CONFIG:invalid_configuration if the
            % particular cluster is not available
            theCluster.check_availability();
            
            config_store.instance().store_config(...
                obj,'parallel_framework',the_name);
            all_configs = theCluster.get_cluster_configs_available();
            % if the config file is not among all existing configurations,
            % change current framework configuration to the default one for
            % the current framework.
            
            if ~ismember(all_configs,obj.cluster_config)
                obj.cluster_config = all_configs{1};
            end
            % The default cluster configuration may be different for different
            % frameworks, so change default cluster configuration to the
            % one, suitable for the selected framework.
            obj.cluster_config_ =all_configs{1};
            
        end
        
        %-----------------------------------------------------------------
        function controller = start_cluster(obj,n_workers,cluster_to_host_exch_fmwork)
            % return the initialized default MPI cluster.
            log_level = config_store.instance().get_value('herbert_config','log_level');
            fram = obj.parallel_framework;
            controller = obj.known_frameworks_(fram);
            %
            controller = controller.init(n_workers,cluster_to_host_exch_fmwork,log_level);
        end
        
    end
    
    
end

