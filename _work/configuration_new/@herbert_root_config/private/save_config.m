function [ok,mess] = save_config (file_name, config_data)
% Save configuration structure
%
%   >> [ok,mess] = save_config (file_name, config_data)
%
%   file_name       Full name of file to hold configuration stucture
%   config_data     Structure holding the configuration
%
%   ok              true if saved ok; false otherwise
%   mess            message if not ok (empty otherwise)

% $Revision: 122 $ ($Date: 2011-12-23 16:33:53 +0000 (Fri, 23 Dec 2011) $)


% Delete existing configuration file, if there is one
if exist(file_name,'file')
    try
        delete(file_name)
    catch
        ok=false;
        mess=['Unable to delete existing configuration data file: ',file_name];
        return
    end
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
