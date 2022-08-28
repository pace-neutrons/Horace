function obj = set_pc_specific_config_(obj,current_pc)
% sets the configuration, specific for the given pc type, as current
% configuration of the class.
%
config_data = obj.all_known_configurations_;
if ~isfield(config_data,current_pc)
    warning('No optimal configuration is stored for this type of the computer (%s). Current configuration left unchanged',...
        current_pc);
    return;
end
obj.current_config_ = config_data.(current_pc);
%
% ensure that optimal configuration memory chunk is smaller then 
% the 0.8 of available memory
hc = obj.current_config_.hor_config;
if hc.mem_chunk_size*obj.DEFAULT_PIX_SIZE > 0.8*obj.this_pc_memory_
    hc.mem_chunk_size = floor(0.8*obj.this_pc_memory_/obj.DEFAULT_PIX_SIZE);
    obj.current_config_.hor_config = hc;
end
