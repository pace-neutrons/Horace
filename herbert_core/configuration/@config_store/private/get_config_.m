function [config_data,got_from_file]=get_config_(obj,class_to_restore,use_defaults_for_missing)
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
% use_defaults_for_missing
%                  -- if true retrieve class defaults if the filed is not
%                     stored in configuration in memory or in file.
%
%Returns:
% config_data -- the structure, containing essential part of appropriate config class
%                with its fields loaded from storage or
%                their default values if all storages are empty.
% got_from_file-- true, if the data were loaded from file, or false,
%                 if they have already been located in memory.
%
% Additionally, it class instance was not in memory, it loaded in memory
% and keeps it there for further usage, if use_default_for_missing is true.
%
%
%

if ischar(class_to_restore)
    class_name = class_to_restore;
    class_to_restore = feval(class_name);
else
    class_name = class_to_restore.class_name;
end

% if class exist in memory, return it from memory;
if isfield(obj.config_storage_,class_name)
    config_data = obj.config_storage_.(class_name);
    got_from_file = false;
else
    filename = fullfile(obj.config_folder,[class_name,'.mat']);
    class_fields = class_to_restore.get_storage_field_names();
    [config_data,result,mess] = load_config_from_file(filename,class_fields);
    got_from_file = true;

    if result ~= 1
        % problems with loading
        if class_to_restore.warn_if_missing_config
            if result == 0 % outdated configuration.
                warning('HERBERT:config_store:outdated_configuration',...
                    'Stored configuration for class: %s is outdated\n The configuration has been reset to defaults ',class_name);
            elseif use_defaults_for_missing % -1
                warning('HERBERT:config_store:default_configuration',...
                    ['Custom configuration for class: %s does not exist\n',...
                    ' The configuration has been set to defaults. Type:\n',...
                    '>>%s\n   to check if defaults are correct'],...
                    class_name,class_name);
            end
        end
        if is_file(filename)
            delete(filename);
        end
        got_from_file = false;
    end
    if isempty(config_data)
        if use_defaults_for_missing % get defaults if unable to load from file
            config_data = class_to_restore.get_defaults();
            got_from_file = false;
        else
            return;
        end
    end


    % set values loaded from file as memory values
    obj.config_storage_.(class_name) = config_data;

    % get default value for saveable state of the configuration
    if ~obj.saveable_.isKey(class_name)
        obj.saveable_(class_name)=class_to_restore.get_saveable_default();
    end
end
