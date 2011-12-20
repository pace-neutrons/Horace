function file_name = config_file_name (config_name)
% Name of file containing configuration data
%
% $Revision$ ($Date$)
%

root_config_name = mfilename('class');
fetch_default=false;
config_data = config_store(root_config_name,fetch_default);
file_name=fullfile(config_data.config_folder_path, [config_name,'.mat']);
