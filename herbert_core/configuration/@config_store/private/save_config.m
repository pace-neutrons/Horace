function save_config (file_name, config_data)
% Save configuration structure to file
%
%   >> save_config (file_name, config_data_class)
%
% Input:
% ------
%   file_name          Full name of file to hold configuration stucture
%   config_data_class  Class holding the structure with configuration
%
% Output:
% -------
%   Throws error  HERBERT:config_store:io_error if problem with saving
%
%   Stores current configuration in file with the name of the class on
%   success.


% Delete existing configuration file, if there is one
if is_file(file_name)
    try
        delete(file_name)
    catch ME
        ERR = MException('HERBERT:config_store:io_error', ...
            sprintf('Unable to delete existing configuration data file: %s', ...
            filename));
        ERR.addCause(ME);
        throw(ERR);
    end
end
config_folder = fileparts(file_name);
if ~(is_folder(config_folder))
    mkdir(config_folder,'s');
end

% Save structure
try
    save(file_name,'config_data')
catch ME
    ERR = MException('HERBERT:config_store:io_error', ...
        sprintf('Unable to save configuration to file: %s', ...
        file_name));
    ERR.addCause(ME);
    throw(ERR);
end

