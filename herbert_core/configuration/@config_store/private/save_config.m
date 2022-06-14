function [ok,mess] = save_config (file_name, config_data)
% Save configuration structure to file
%
%   >> [ok,mess] = save_config (file_name, config_data_class)
%
% Input:
% ------
%   file_name          Full name of file to hold configuration stucture
%   config_data_class  Class holding the structure with configuration
%
% Output:
% -------
%   ok              true if saved ok; false otherwise
%   mess            message if not ok (empty otherwise)

% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


% Delete existing configuration file, if there is one
if is_file(file_name)
    try
        delete(file_name)
    catch
        ok=false;
        mess=['Unable to delete existing configuration data file: ',file_name];
        return
    end
end
config_folder = fileparts(file_name);
if ~(is_folder(config_folder))
    mkdir(config_folder,'s');
end

% Save structure
try
    save(file_name,'config_data')
    ok=true;
    mess='';
catch
    ok=false;
    mess=['Unable to save configuration to file: ',file_name];
    return
end

