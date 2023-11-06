function out = get_config_field_(obj,class_to_restore, ...
    field_is_missing_warning,varargin)

if isa(class_to_restore,'config_base')
    class_name = class_to_restore.class_name;
elseif istext(class_to_restore)
    class_name = class_to_restore;
    class_to_restore = feval(class_name);
else
    error('HERBERT:config_store:invalid_argument',...
        'Config class has to be a child of the config_base class or the name of such class');
end

if isfield(obj.config_storage_,class_name)
    config_data = obj.config_storage_.(class_name);
else
    config_data = get_config_(obj,class_to_restore);
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
        if field_is_missing_warning
            warning('HERBERT:config_store:restore_config',...
                'Class %s field %s is not stored in configuration. Returning defaults',...
                class_name,varargin{i});
        end
        out{i} = class_to_restore.get_default_value(varargin{i});
    end
end
