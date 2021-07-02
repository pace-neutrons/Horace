function [config_data,got_from_file]=get_config_(this,class_to_restore)
% method returns the essential (storable) content of the configuration 
% class requested as input 
%
% If the class is already in memory, it returns the class instance, stored in memory. 
%
% If it is not, it loads the class configuration from the hard drive or, if
% the configuration is not stored, instantiates the class (or uses the
% instance of the input configuration class) and returns these values. 
%
%input:
% class_to_restore -- instance of the class to restore from HDD (memory if
%                     already loaded) or the name of this class. 
%
%Returns:
% the structure, conatining instance with its fields loaded from storage or
% their default values if all storages are empty. 
% 
% Additionally, it class instance was not in memory, it loaded in memory
% and stays there for further usage. 
%
%
if ischar(class_to_restore)
    class_name = class_to_restore;
    class_to_restore = feval(class_name);
else
    class_name = class_to_restore.class_name;
end

% if class exist in memory, return it from memory;
if isfield(this.config_storage_,class_name)
    config_data = this.config_storage_.(class_name);
    got_from_file = false;
else
    filename = fullfile(this.config_folder,[class_name,'.mat']);
    class_fields = class_to_restore.get_storage_field_names();
    [config_data,result,mess] = load_config_from_file(filename,class_fields);
    got_from_file = true;    
    
    if result ~= 1
        % problems with loading
        if result == 0 % outdated configuration.
            warning('HERBERT:config_store:runtime_error',...
                'Stored configuration for class: %s is outdated\n The configuration has been reset to defaults ',class_name);
        else
            warning('HERBERT:config_store:runtime_error',...
                ['Custom configuration for class: %s does not exist\n',...
                   ' The configuration has been set to defaults. Type:\n',...
                   '>>%s\n   to check if defaults are correct'],...
                   class_name,class_name);            
        end
        if is_file(filename)
            delete(filename);
        end
        got_from_file = false;
    end
    
    % set obtained config data into storage.
    try
        if isempty(config_data) % get defaults
            config_data = class_to_restore.get_defaults();
            got_from_file = false;                
        end
    catch ME
        if (strcmp(ME.identifier,'MATLAB:noSuchMethodOrField'))
            warning('CONFIG_STORE:restore_config','Stored configuration for class: %s is outdated\n The configuration has been reset to defaults ',class_name);
            if is_file(filename)
                delete(filename);
            end
            got_from_file = false;                            
        else
            rethrow(ME);
        end
    end
    this.config_storage_.(class_name) = config_data;
    % this returns current state of saveable property and if it is not
    % set, returns default state of the object.
    if ~this.saveable_.isKey(class_name)
        this.saveable_(class_name)=class_to_restore.get_saveable_default();
    end
    % if the class has been loaded from file, set-up its active properties,
    % in case they perform more then 
    
end
