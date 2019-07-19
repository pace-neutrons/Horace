function  save_configurations_(obj,info)
% assuming the current configuration is the optimal one, save the
% configuration on HDD for future usage.

full_config_file = fullfile(obj.config_info_folder,obj.config_filename);

% read existing configuration file, to keep the configurations for all
% other known types of pc intact.
if exist(full_config_file,'file')
    data_struct = xml_read(full_config_file);
else
    data_struct = struct();
end

% create structure describing this pc configuration and set-up info field
% as the first field in the structure.
if exist('info','var')
    this_pc_config = struct('info',info);
else
    this_pc_config = struct('info','');
end
% Retrieve all known configurations and fill-in structure, containing this
% configurations with the name of the configuration files as the fieldnames
% of the structure.
n_configs = numel(obj.known_configs_);
for i=1:n_configs
    config_name = obj.known_configs_{i};
    cfg = feval(config_name());
    this_pc_config.(config_name) = cfg.get_data_to_store();
end
this_pc_type = obj.this_pc_type;

% set up the configuration for this pc as the field of the whole
% configuration structure.
data_struct.(this_pc_type) = this_pc_config;

% store configuration in the xml file for further usage.
xml_write(full_config_file,data_struct);