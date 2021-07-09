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
        framework_available_ = true;
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
                obj.framework_available_ = false;
            else
                obj.framework_available_ = true;
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
            if obj.framework_available_
                cl = obj.known_clusters_(obj.parallel_cluster_name_);
            else
                cl  = [];
            end
        end
        function is = get.framework_available(obj)
            is = obj.framework_available_;
        end
        function cl = get_default_cluster(obj)
            % get current cluster regardless of it is available or not
            cl = obj.known_clusters_(obj.parallel_cluster_name_);
        end
        function cl = get_cluster(obj,varargin)
            % legacy function allowing to obtain the current cluster, or
            % the cluster requested as input
            if nargin >1
                obj.parallel_cluster = varargin{1};
            end
            cl = obj.parallel_cluster;
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
            % If the cluster is not available, it is still set up as the
            % internal cluster, but the framework_available property of the
            % cluster factory is set up to false, so get_cluster function
            % would return empty value.
            select_and_set_working_parallel_cluster_(obj,val);
        end
        %
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
            try
                cl= cl.init(n_workers,cluster_to_host_exch_fmwork,log_level);
            catch ME
                if strcmp(ME.identifier,'HERBERT:ClusterWrapper:runtime_error')
                    if log_level > -1
                        fprintf(2,'*** Cluster Initialization failure: %s\n',ME.message);
                    end
                    cl=[];
                else
                    rethrow(ME);
                end
            end
            
        end
        
    end
end