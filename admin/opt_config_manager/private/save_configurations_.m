function  save_configurations_(obj)
% assuming the current configuration is the optimal one, save the
% configuration on HDD for future usage.

full_config_file = fullfile(obj.config_info_folder,obj.config_filename);

if exist(full_config_file,'file')
    data_struct = read_xml(full_config_file);
else
    data_struct = struct();
end


this_pc_config = struct();
n_configs = numel(obj.known_configs_);
for i=1:n_configs 
    config_name = obj.known_configs_{i};
    cfg = feval(config_name());
    this_pc_config.(config_name) = cfg.get_data_to_store();
end
this_pc_type = obj.this_pc_type;
data_struct.(this_pc_type) = this.pc.config;
%
xml_write(full_config_file,data_struct);