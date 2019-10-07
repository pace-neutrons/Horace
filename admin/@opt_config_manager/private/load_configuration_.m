function conf = load_configuration_(obj,set_config,set_def_only,force_save)
% method loads the previous configuration, which
% stored as optimal for this computer and, if set_config option is true,
% configures Horace and Herbert using loaded configurations
%
% Returns the structure, containing used configurations info.
%
conf = [];
config_file = fullfile(obj.config_info_folder,obj.config_filename);
if ~(exist(config_file,'file') == 2)
    warning('No existing configuration file %s found. Current configuration left unchanged',...
        config_file)
    return;
end
config_data = xml_read(config_file);

current_pc = obj.this_pc_type;
if ~isfield(config_data,current_pc)
    warning('No optimal configuration is stored for this type of the computer (%s). Current configuration left unchanged',...
        current_pc);
    return;
end
conf =config_data.(current_pc);
if ~set_config
    return
end
flds = fieldnames(conf);
for i=1:numel(flds)
    if strcmpi(flds{i},'info') % skip info string
        continue;
    end
    conf_cl = feval(flds{i});
    if set_def_only
        if ~conf_cl.is_default
            continue
        end
    end
    settings = conf.(flds{i});
    conf_cl.set_stored_data(settings);
    if force_save
        config_store.instance().store_config(conf_cl,'-forcesave');
    end

end