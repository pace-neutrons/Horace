function out = set_config_field_value_(obj,class_or_name_to_restore, varargin)
% GET_CONFIG_FIELD_VALUE_ returns the field or celarray of fields values for
% the list of config properties, provided as input.
%
% If config class is not loaded in memory, it is restored from the hard
% drive. If configuration is not present on the hard drive, the default
% configuration is returned.
%
% Input:
% obj              -- initialized instance of config_store class
% class_or_name_to_restore
%                  -- name or instance of config class to set field to. 
%                     field value is not validated
% varargin         -- contains the list of the configuration properties to
%                     restore
% Returns:
% out              -- cellarray of property values corresponding to the
%                     property names, provided as input


if isa(class_or_name_to_restore,'config_base')
    class_name = class_or_name_to_restore.class_name;
    class_inst  = class_or_name_to_restore;
elseif istext(class_or_name_to_restore)
    class_name = class_or_name_to_restore;
    class_inst = feval(class_name);
else
    error('HERBERT:config_store:invalid_argument',...
        'Config class %s has to be a child of the config_base class or the name of such class', ...
        class(class_or_name_to_restore));
end

if isfield(obj.config_storage_,class_name)
    config_data = obj.config_storage_.(class_name);
else
    config_data = obj.get_config(class_inst);
end

if numel(varargin) < nargout
    error('HERBERT:config_store:runtime_error',...
        ' some output values are not set by this function call');
end


nfields = numel(varargin)/2;
if rem(numel(varargin),2)>eps('double')
    error('HERBERT:config_store:invalid_argument',...    
        'Number of provided fields is not equal to number of their values')
end

for i=1:nfields
    if isfield(config_data,varargin{2*i-1})
        config_data.(varargin{2*i-1}) = varargin{2*i};
    else
        warning('HERBERT:config_store:unknown_field',...
                'Class %s field %s is not stored in configuration. Ignore stroing this field value',...
                class_name,varargin{2*i-1});
    end
end
obj.config_storage_.(class_name) = config_data;
