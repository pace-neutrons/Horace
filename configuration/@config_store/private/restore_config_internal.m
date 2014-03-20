function obj=restore_config_internal(this,class_to_restore)
% method loads class configuration from the hard drive
%
% $Revision: 278 $ ($Date: 2013-11-01 20:07:58 +0000 (Fri, 01 Nov 2013) $)


class_name = class_to_restore.class_name;
% if class exist in memory, return it from memory;
if isfield(this.config_storage_,class_name)
    obj=this.config_storage_.(class_name);
else
    filename = fullfile(this.config_folder,[class_name,'.mat']);
    class_fields = fieldnames(class_to_restore);
    [obj,result,mess] = load_config (filename,class_fields);
    
    if result ~= 1
        % problems with loading
        if result == 0 % outdated configuration.
            obj = class_to_restore;
            warning('CONFIG_STORE:restore_config','Stored configuration for class: %s is outdated\n The configuration has been reset to defaults ',class_name);
        else
            error('CONFIG_STORE:restore_config',mess);
        end
        if exist(filename,'file')
            delete(filename);
        end       
    end
    if ~isempty(obj)
        this.config_storage_.(class_name)= obj;
    end
end
