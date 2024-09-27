function obj = check_and_set_cluster_(obj,cluster_name)
% Set up MPI cluster to use.
%
% Available options defined by known_clusters and are
% defined in MPI_clusters_factory
%
% The cluster name (can be defined by single symbol)
% or by a cluster number in the list of clusters
%
assert(~isempty(which(obj.worker)) || exist(obj.worker, 'file'), ...
    'HERBERT:parallel_config:runtime_error', ...
    'Parallel worker is not on the Matlab path so parallel features are not available');

mff = MPI_clusters_factory.instance();
known_clusters = mff.known_cluster_names;
full_cl_name = obj.select_option(known_clusters,cluster_name);
% cluster is instantiated both in framework, and in configuration
mff.parallel_cluster = full_cl_name;

if ~mff.framework_available % if cluster available, store its name in
    error('HERBERT:parallel_config:runtime_error',...
        'Cluster %s is not available on the current system',...
        full_cl_name);
end

if obj.do_check_combo_arg
    % here we will store cluster name in configuration to recover it when
    % starting from scratch
    obj = obj.check_combo_arg();
end

