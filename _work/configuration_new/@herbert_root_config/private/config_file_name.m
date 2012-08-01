function file_name = config_file_name (config_name)
% Name of file containing configuration data

% $Revision: 165 $ ($Date: 2012-02-28 10:47:57 +0000 (Tue, 28 Feb 2012) $)

%--> the block to provide compartibility between matlab 2008a and 2007b where
% mfilename behaviour changes
[fd,ff]=fileparts(mfilename('class'));
if isempty(fd) 
    root_config_name = ff;
else
    root_config_name = fd;
end
%<--
fetch_default=false;
config_data = config_store(root_config_name,fetch_default);
file_name=fullfile(config_data.config_folder_path, [config_name,'.mat']);
