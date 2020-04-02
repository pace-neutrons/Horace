function obj = set_pc_specific_config_(obj,config_data,current_pc)
% sets configuration, specific for the given pc type, as current
% configuration of the class.
if ~isfield(config_data,current_pc)
    warning('No optimal configuration is stored for this type of the computer (%s). Current configuration left unchanged',...
        current_pc);
    return;
end
obj.current_config_ = config_data.(current_pc);
