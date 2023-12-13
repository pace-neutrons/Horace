function cleanup_handle = set_temporary_config_options(config_instance, varargin)
% SET_TEMPORARY_CONFIG_OPTION set some config options and return an onCleanup object that
% will reset the config when it goes out of scope
%
% >> cleanup_handle = set_temporary_config_option(hor_config(), 'mem_chunk_size', 20e6);
%
% >> cleanup_handle = set_temporary_config_option(hor_config(), 'use_mex', true, 'threads', 4);
%
if nargout ~= 1
    error('TEST:set_temporary_config_option', 'Function requires 1 output argument.');
end
if istext(config_instance)
    config_instance = feval(config_instance);
end

original_config = config_instance.get_all_configured();
cleanup_handle = onCleanup(@() restore(config_instance,original_config));
% stop changes from being stored on disk.
config_instance.saveable = false;

for i = 1:2:numel(varargin)
    config_field = varargin{i};
    value = varargin{i + 1};
    config_instance.(config_field) = value;
end

end

function restore(config_instance,original_config)
% disable setup warning on restoring properties (where properties support this)
config_instance.disable_setup_warnings = true;
% restore original configuration
set(config_instance, original_config);
% change class to be saveable again, so that configuration changes to be
% stored in file and not just kept in memory.
config_instance.saveable = true;

end
