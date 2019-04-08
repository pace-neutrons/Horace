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

% $Revision:: 830 ($Date:: 2019-04-08 16:16:02 +0100 (Mon, 8 Apr 2019) $)


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
