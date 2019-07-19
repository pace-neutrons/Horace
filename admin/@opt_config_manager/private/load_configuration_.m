function conf = load_configuration_(obj)
% method loads the previous configuration, which
% stored as optimal for this computer and configures
% Horace and Herbert using loaded configurations
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
flds = fieldnames(conf);
for i=1:numel(flds)
    if strcmpi(flds{i},'info') % skip info string
        continue;
    end
    conf_cl = feval(flds{i});
    settings = conf.(flds{i});
    conf_cl.set_stored_data(settings);
end