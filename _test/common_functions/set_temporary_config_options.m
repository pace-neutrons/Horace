function cleanup_handle = set_temporary_config_options(config_instance, varargin)
%% SET_CONFIG_OPTION set some config options and return an onCleanup object that
% will reset the config when it goes out of scope
%
% >> cleanup_handle = set_config_option(hor_config(), 'mem_chunk_size', 20e6);
%
% >> cleanup_handle = set_config_option(hor_config(), 'use_mex', true, 'threads', 4);
%
if nargout ~= 1
    error('TEST:set_config_option', 'Function requires 1 output argument.');
end

original_config = config_instance.get_data_to_store();
cleanup_handle = onCleanup(@()restore(config_instance,original_config));
config_instance.saveable = false;

for i = 1:2:numel(varargin)
    config_field = varargin{i};
    value = varargin{i + 1};
    config_instance.(config_field) = value;
end

function restore(config_instance,original_config)

set(config_instance, original_config);
config_instance.saveable = true;
