function cleanup = set_config_option(config_instance, fields, values)
%% SET_CONFIG_OPTION set a config option and return an onCleanup object that
% will reset the config when it goes out of scope
%
if nargout ~= 1
    error('TEST:set_config_option', 'Function requires 1 output argument.');
end

if ischar(fields)
    fields = {fields};
end
if ~isa(values, 'cell')
    values = {values};
end

original_config = config_instance.get_data_to_store();
for i = 1:numel(fields)
    set(config_instance, fields{i}, values{i});
end

cleanup = onCleanup(@() set(config_instance, original_config));
