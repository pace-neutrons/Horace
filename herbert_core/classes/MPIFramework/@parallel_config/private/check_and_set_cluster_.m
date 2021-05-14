function obj = check_and_set_cluster_(obj,cluster_name)
% Set up MPI cluster to use.
%
% Available options defined by known_clusters and are
% defined in MPI_clusters_factory
%
% The cluster name (can be defined by single symbol)
% or by a cluster number in the list of clusters
%
wrkr = which(obj.worker_);
mff = MPI_clusters_factory.instance();

if isempty(wrkr)
    error('HERBERT:parallel_config:not_available',...
        'Parallel worker is not on the Matlab path so parallel features are not available')
else
    known_clusters = mff.known_cluster_names;
    full_cl_name = obj.select_option(known_clusters,cluster_name);
    mff.parallel_cluster = full_cl_name;
    
    if mff.framework_available % if cluster available, store it in the configuration
        config_store.instance().store_config(...
            obj,'parallel_cluster',full_cl_name);
        cluser_changed = true;
    else
        cluser_changed = false;
    end
    
    if cluser_changed % default cluster configuration may also need to
        % be changed
        % retrieve possible configs for current cluster
        cluster_configs = mff.get_all_configs(full_cl_name);
        % what config is currently there
        cur_config = config_store.instance().get_value(...
            obj,'cluster_config');
        if ~ismember(cur_config,cluster_configs)
            % update default configuration if the previous configuration
            % does not correspond to this cluster configuration
            config_store.instance().store_config(...
                obj,'cluster_config',cluster_configs{1});
        end
    else
        error('HERBERT:parallel_config:not_available',...
            'Cluster %s is not available on the current system',...
            full_cl_name);
    end
end
