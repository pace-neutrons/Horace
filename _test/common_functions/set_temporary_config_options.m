function cleanup_handle = set_temporary_config_options(config_instance, varargin)
%% SET_CONFIG_OPTION set some config options and return an onCleanup object that
% will reset the config when it goes out of scope
%
% >> cleanup_handle = set_config_option(hor_config(), 'pixel_page_size', 100e6);
%
% >> cleanup_handle = set_config_option(hor_config(), 'use_mex', true, 'threads', 4);
%
if nargout ~= 1
    error('TEST:set_config_option', 'Function requires 1 output argument.');
end

original_config = config_instance.get_data_to_store();
cleanup_handle = onCleanup(@() set(config_instance, original_config));

for i = 1:2:numel(varargin)
    config_field = varargin{i};
    value = varargin{i + 1};
    set(config_instance, config_field, value);
end
