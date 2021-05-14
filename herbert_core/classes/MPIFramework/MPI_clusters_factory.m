classdef MPI_clusters_factory<handle
    % The class, providing the subscription factory for
    % various type of MPI frameworks, available to users.
    %
    % Any new type of framework should subscribe to this factory.
    %
    % Implemented as classical singleton.
    %
    properties(Dependent)
        % the name of current active cluster
        parallel_cluster_name;
        
        % boolean property, replying true if the cluster with selected name 
        % is available or false if not
        framework_available
        
        % access to current active cluster
        parallel_cluster;

        % Information (read-only) method returning the list of names of 
        % the parallel frameworks, known to Herbert. 
        % You can not add or change a framework using this method.
        % The framework has to be defined and subscribed via the 
        % algorithms factory.
        known_cluster_names
        %
    end
    properties(Access=protected)
        % the name of the cluster, used as default
        parallel_disabed_ = false;
        parallel_cluster_name_ = 'herbert';
    end
    properties(Constant, Access=protected)
        % Subscription factory:
        % the list of the known framework names.
        known_cluster_names_ = {'herbert','parpool','mpiexec_mpi','slurm_mpi'};
        % The map to existing parallel frameworks clusters
        known_clusters_ = containers.Map(MPI_clusters_factory.known_cluster_names_,...
            {ClusterHerbert(),ClusterParpoolWrapper(),ClusterMPI(),ClusterSlurm()});
        % the map of the framework indexes
        cluster_ids_ = containers.Map(MPI_clusters_factory.known_cluster_names_,...
            num2cell(1:4));
        
    end
    %----------------------------------------------------------------------
    methods(Access=private)
        function obj=MPI_clusters_factory()
            cluster_name = config_store.instance().get_value(...
                'parallel_config','parallel_cluster');
            if strcmp(cluster_name,'none')
                cluster_name = 'herbert';
                obj.parallel_disabed_ = true;
            else
                obj.parallel_disabed_ = false;
            end
            obj.parallel_cluster_name_ = cluster_name;
        end
    end
    %----------------------------------------------------------------------
    methods(Static)
        function obj = instance(varargin)
            persistent obj_state;
            if isempty(obj_state)
                obj_state = MPI_clusters_factory();
            end
            obj=obj_state;
        end
    end
    %----------------------------------------------------------------------
    methods
        %------------------------------------------------------
        function cl = get.parallel_cluster(obj)
            if obj.parallel_disabed_
                cl  = [];
            else
                cl = obj.known_clusters_(obj.parallel_cluster_name_);
            end
        end       
        function is = get.framework_available(obj)
            is = ~obj.parallel_disabed_;
        end
        function cl = get_default_cluster(obj)
            % get current cluster regardless of it is available or not
            cl = obj.known_clusters_(obj.parallel_cluster_name_);
        end
        function cn = get.parallel_cluster_name(obj)
            cn = obj.parallel_cluster_name_;
        end
        
        function set.parallel_cluster(obj,val)
            % Set up MPI cluster to use. Available options are:
            % h[erbert], p[arpool], m[pi_cluster] or s[lurm]
            % (can be defined by single symbol) or by a framework number
            % in the list of frameworks.
            %
            % No protection against invalid input key or cluster availability
            % is provided here so
            % use parallel_config to get this protection, or organize it
            % before the call. Throws invalid_key for unknown framework
            % names.
            %
            if isa(val,'ClusterWrapper')
                cl_name = class(val);
                if ~ismember(cl_name,obj.known_cluster_names_)
                    error('HERBERT:MPI_clusters_factory:invalid_argument',...
                        'Cluster with name %s is not subscribed to factory',val);
                end
                obj.known_clusters_(cl_name) = val;
            else
                if ~ismember(val,obj.known_cluster_names_)
                    error('HERBERT:MPI_clusters_factory:invalid_argument',...
                        'Setting the cluster with unknown name %s',val);
                else
                    cl_name = val;
                end
            end
            obj.parallel_cluster_name_ = cl_name;
            cl = obj.known_clusters_(cl_name);
            try
                cl.check_availability();
            catch ME
                if strcmp(ME.identifier,'HERBERT:ClusterWrapper:not_available')
                    obj.parallel_disabed_ = true;
                    return
                else
                    rethrow(ME);
                end
            end
            obj.parallel_disabed_ = false;
            %
        end
        function cfg = get_all_configs(obj,varargin)
            % return all known configurations for the selected framework.
            % (cluster)
            % if the cluster name is provided as input, get possible
            % configurations for that cluster
            if nargin>1
                cl_name = varargin{1};
            else
                cl_name = obj.parallel_cluster_name_;
            end
            cl = obj.known_clusters_(cl_name);
            cfg = cl.get_cluster_configs_available();
        end
        
        %
        function clusters = get.known_cluster_names(obj)
            clusters = obj.known_cluster_names_;
        end
        
        %-----------------------------------------------------------------
        function cl = get_initialized_cluster(obj,n_workers,cluster_to_host_exch_fmwork)
            % return the initialized and running MPI cluster, selected as default
            % Inputs:
            % n_workers -- number of running workers
            % cluster_to_host_exch_fmwork -- the instance of the messaging
            %              framework, used for initial communication with
            %              the cluster. Currently FileBased only
            % Returns:
            % cl -- the initialized instance of the cluster,
            %       selected as current in parallel_config. The
            %       cluster controls the requested number of the
            %       parallel workers, communicating between each
            %       other using the method, chosen for the
            %       cluster.
            log_level = config_store.instance().get_value('herbert_config','log_level');
            cl      = obj.parallel_cluster;
            if isempty(cl)
                error('HERBERT:MPI_clusters_factory:not_available',...
                    ' Can not run jobs in parallel. Any parallel framework is not available. Worker may be not installed.')
            end
            %
            cl= cl.init(n_workers,cluster_to_host_exch_fmwork,log_level);
        end
        
    end
    
    
end

