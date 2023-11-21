function is = is_field_configured_(obj,class_inst_or_name,field_name)
% IS_FIELD_CONFIGURED_ % Check if the specified field from specified
% configuration class has non-default value

config_data=get_config_(obj,class_inst_or_name,false);
if isempty(config_data)
    is = false;
else
    is = isfield(config_data,field_name);
end
