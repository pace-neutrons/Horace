function out =get_config_val_internal(obj,class_name,varargin)
% method loads class configuration from the hard drive
%
%input:
% class_name -- name of the class to restore value from HDD or memory if
%               already loaded or the instance of such class
%
% varargin   -- the cellarray of the names of the properties to retrieve
%               stored values from
%
%Returns:
% out        -- cellarray, containing the value(s) of the requested property(ies).
%

if isa(class_name,'config_base') % should be class instance;
    class_to_restore  = class_name;
    class_name = class_to_restore.class_name;
elseif ischar(class_name)
    if ~isfield(obj.config_storage_,class_name)
        % get class instance to work with recovery/defaults
        class_to_restore = feval(class_name);
    end
else
    error('CONFIG_STORE:invalid_argument',...
        'invalid data type to restore values for');
end

% if class exist in memory, return it from memory;
if isfield(obj.config_storage_,class_name)
    config_data = obj.config_storage_.(class_name);
else
    filename = fullfile(obj.config_folder,[class_name,'.mat']);
    class_fields = class_to_restore.get_storage_field_names();
    [config_data,result,mess] = load_config_from_file(filename,class_fields);

    switch result
        case 0 % outdated configuration.
            warning('CONFIG_STORE:restore_config','Stored configuration for class: %s is outdated\n The configuration has been reset to defaults ',class_name);
            if is_file(filename)
                delete(filename);
            end
        case -1 % problems with loading
            warning('CONFIG_STORE:restore_config',['Error in loading stored configuration: %s\n',...
                'Custom configuration for class: %s can not be restored\n',...
                ' The configuration has been set to defaults. Type:\n',...
                '>>%s\n   to check if defaults are correct'],mess,class_name,class_name);
            if is_file(filename)
                delete(filename);
            end
    end

    % set obtained config data into storage.
    try
        if isempty(config_data) % get defaults
            config_data = class_to_restore.get_data_to_store();
        end
    catch ME
        switch ME.identifier
            case 'MATLAB:noSuchMethodOrField'
                warning('CONFIG_STORE:restore_config','Stored configuration for class: %s is outdated\n The configuration has been reset to defaults ',class_name);
                if is_file(filename)
                    delete(filename);
                end
            otherwise
                rethrow(ME);
        end
    end
    % store obtained data in class memory
    obj.config_storage_.(class_name) = config_data;
    % this returns current state of saveable property and if it is not
    % set, returns default state of the object.
    if ~obj.saveable_.isKey(class_name)
        obj.saveable_(class_name)=class_to_restore.get_saveable_default();
    end

end

nout = numel(varargin);
out = cell(nout,1);
for i=1:nout
    prop_name = varargin{i};
    if isfield(config_data,prop_name)
        prop_value = config_data.(prop_name);
    else
        prop_value = class_to_restore.get_default_value(prop_name);
    end
    out{i} = prop_value;
end
