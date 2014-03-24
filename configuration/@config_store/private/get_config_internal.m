function config_data=get_config_internal(this,class_to_restore)
% method loads class configuration from the hard drive
%
%input:
% class_to_restore -- instance of the class to restore from HDD (memory if
%                     already loaded)
% varargin         -- if present, list of the class_to_restore field names
%                     which values function expects to return
%Returns:
% 
% the object with its fields loaded from storage if varargin is empty
% 
% the list of values of the class_to_restore fields with names specified in
%            varargin
%
% $Revision: 278 $ ($Date: 2013-11-01 20:07:58 +0000 (Fri, 01 Nov 2013) $)
%

class_name = class_to_restore.class_name;

% if class exist in memory, return it from memory;
if isfield(this.config_storage_,class_name)
    config_data = this.config_storage_.(class_name);
else
    filename = fullfile(this.config_folder,[class_name,'.mat']);
    class_fields = class_to_restore.get_storage_field_names();
    [config_data,result,mess] = load_config_from_file(filename,class_fields);
    
    if result ~= 1
        % problems with loading
        if result == 0 % outdated configuration.
            warning('CONFIG_STORE:restore_config','Stored configuration for class: %s is outdated\n The configuration has been reset to defaults ',class_name);
        else
            error('CONFIG_STORE:restore_config',mess);
        end
        if exist(filename,'file')
            delete(filename);
        end       
    end
    % set obtained config data into storage. 
    if isempty(config_data) % get defaults
        config_data = class_to_restore.get_data_to_store();
    end
     this.config_storage_.(class_name) = config_data;
end

