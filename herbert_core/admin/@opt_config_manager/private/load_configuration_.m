function obj = load_configuration_(obj,set_config,set_defaults_only,force_save)
% method loads the previous configuration, which
% stored as optimal for this computer and, if set_config option is true,
% configures Horace and Herbert using loaded configurations
%
% returns the object, with the configuration data, choosen as default for
% the selected pc type.
%
%
config_file = fullfile(obj.config_info_folder,obj.config_filename);
if ~(is_file(config_file))
    warning('No existing configuration file %s found. Current configuration left unchanged',...
        config_file)
    return;
end
obj.all_known_configurations_ = xml_read(config_file);

current_pc = obj.this_pc_type;
obj = set_pc_specific_config_(obj,current_pc);
%
if ~set_config
    return
end
set_into_to_config_classes_(obj,set_defaults_only,force_save);
