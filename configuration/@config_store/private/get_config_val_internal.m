function [prop_value,out] =get_config_val_internal(this,class_name,prop_name,varargin)
% method loads class configuration from the hard drive
%
%input:
% class_name -- name of the class to restore value from HDD or memory if
%                     already loaded
% prop_name  -- the name of the property to get stored value
%
%Returns:
%
% the value of the requested property.
%
%
% $Revision: 536 $ ($Date: 2016-09-26 16:02:52 +0100 (Mon, 26 Sep 2016) $)
%


% if class exist in memory, return it from memory;
if isfield(this.config_storage_,class_name)
    config_data = this.config_storage_.(class_name);
else
    class_to_restore = feval(class_name);
    filename = fullfile(this.config_folder,[class_name,'.mat']);
    class_fields = class_to_restore.get_storage_field_names();
    [config_data,result,mess] = load_config_from_file(filename,class_fields);
    
    if result ~= 1
        % problems with loading
        if result == 0 % outdated configuration.
            warning('CONFIG_STORE:restore_config','Stored configuration for class: %s is outdated\n The configuration has been reset to defaults ',class_name);
        else
            warning('CONFIG_STORE:restore_config',['Error in loading stored configuration: %s\n',...
                'Custom configuration for class: %s can not be restored\n',...
                ' The configuration has been set to defaults. Type:\n',...
                '>>%s\n   to check if defaults are correct'],mess,class_name,class_name);
        end
        if exist(filename,'file')
            delete(filename);
        end
    end
    
    % set obtained config data into storage.
    try
        if isempty(config_data) % get defaults
            config_data = class_to_restore.get_data_to_store();
        end
    catch ME
        if (strcmp(ME.identifier,'MATLAB:noSuchMethodOrField'))
            warning('CONFIG_STORE:restore_config','Stored configuration for class: %s is outdated\n The configuration has been reset to defaults ',class_name);
            if exist(filename,'file')
                delete(filename);
            end
        else
            rethrow(ME);
        end
    end
    % store obtained data in class memory
    this.config_storage_.(class_name) = config_data;
    % this returns current state of saveable property and if it is not
    % set, returns default state of the object.
    if ~this.saveable_.isKey(class_name)
        this.saveable_(class_name)=class_to_restore.get_saveable_default();
    end
    
end
prop_value = config_data.(prop_name);
other_prop_names = varargin{:};
nout = numel(other_prop_names);
out = cell(nout,1);
for i=1:nout
    out{i} = config_data.(other_prop_names{i});
end


