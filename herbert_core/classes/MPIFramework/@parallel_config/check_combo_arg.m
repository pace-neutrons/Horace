function obj = check_combo_arg(obj)
% Check cluster config against its configuration and set configuration,
% appropriate to the cluster
%

mf = MPI_clusters_factory.instance();
full_cl_name = mf.parallel_cluster_name;
if strcmp(full_cl_name,'none')
    return; % nothing to check, framework is not available
end
% It may be easier to get configs from current cluster, but this is the equivalent.
cluster_configs = mf.get_all_configs(full_cl_name);
% retrieve possible configs for current cluster
if isempty(obj.trial_cluster_config_)
    old_config = config_store.instance().get_value(...
        obj,'cluster_config');
    if ~ismember(old_config ,cluster_configs)
        % update default configuration if the previous configuration
        % does not correspond to this cluster configuration
        the_config   = cluster_configs{1};
    else
        the_config = old_config;
    end
else
    try_config  = obj.trial_cluster_config_;
    the_config  = select_option_(cluster_configs,try_config);
end

% set cluster name and consistent cluster configuration in storage
config_store.instance().store_config(obj,'parallel_cluster',full_cl_name);
config_store.instance().store_config(obj,'cluster_config',the_config);

obj.trial_cluster_config_   = '';
