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
    the_name = 'none';
else
    try
        mff.parallel_cluster = cluster_name;
    catch ME
        if strcmpi(ME.identifier,'PARALLEL_CONFIG:invalid_configuration')
            warning(ME.identifier,'%s',ME.message);
            return;
        elseif strcmpi(ME.identifier,'PARALLEL_CONFIG:not_available')
            warning(ME.identifier,'%s',ME.message);
            return;
        else
            rethrow(ME);
        end
    end
    the_name = mff.parallel_cluster;
end
config_store.instance().store_config(...
    obj,'parallel_cluster',the_name);

all_configs = mff.get_all_configs();
% if the config file is not among all existing configurations,
% change current cluster configuration to the default one for
% the current cluster.
if ~ismember(all_configs,obj.cluster_config)
    obj.cluster_config = all_configs{1};
end
% The default cluster configuration may be different for different
% clusters, so change default cluster configuration to the
% one, suitable for the selected cluster.
obj.cluster_config_ =all_configs{1};
