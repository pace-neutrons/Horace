function obj = check_and_set_frmwk_(obj,frmwk_name)
% Set up MPI framework to use.
%
% Available options defined by known_frameworks and are
% defined in MPI_fmwks_factory
%
% The framework name (can be defined by single symbol)
% or by a framework number in the list of frameworks
%
wrkr = which(obj.worker_);
mff = MPI_fmwks_factory.instance();
if isempty(wrkr)
    the_name = 'none';
else
    try
        mff.parallel_framework = frmwk_name;
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
    the_name = mff.parallel_framework;
end
config_store.instance().store_config(...
    obj,'parallel_framework',the_name);

all_configs = mff.get_all_configs();
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
