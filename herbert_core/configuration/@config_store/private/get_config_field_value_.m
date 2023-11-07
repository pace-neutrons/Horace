function out = get_config_field_value_(obj,class_to_restore, varargin)
% GET_CONFIG_FIELD return the field or celarray of fields values for
% the list of config properties, provided as input.
%
% If config class is not loaded in memory, it is restored from the hard
% drive. If configuration is not present on the hard drive, the default
% configuration is returned.
%
% Input:
% obj              -- initialized instance of config_store class
% class_to_restore -- name or instance of config class to get field from
% varargin         -- contains the list of the configuration properties to
%                     restore
% Returns:
% out              -- cellarray of property values corresponding to the
%                     property names, provided as input


if isa(class_to_restore,'config_base')
    class_name = class_to_restore.class_name;
elseif istext(class_to_restore)
    class_name = class_to_restore;
    class_to_restore = feval(class_name);
else
    error('HERBERT:config_store:invalid_argument',...
        'Config class %s has to be a child of the config_base class or the name of such class', ...
        class(class_to_restore));
end

if isfield(obj.config_storage_,class_name)
    config_data = obj.config_storage_.(class_name);
else
    config_data = obj.get_config(class_to_restore);
end

if numel(varargin) < nargout
    error('HERBERT:config_store:runtime_error',...
        ' some output values are not set by this function call');
end

nfields = numel(varargin);
out = cell(nfields,1);
for i=1:nfields
    if isfield(config_data,varargin{i})
        out{i}=config_data.(varargin{i});
    else
        out{i} = class_to_restore.get_default_value(varargin{i});
        if ~ismember(varargin{i},class_to_restore.mem_only_prop_list)
            warning('HERBERT:config_store:default_field_value',...
                'Class %s field %s is not stored in configuration. Returning defaults',...
                class_name,varargin{i});
        end

    end
end
