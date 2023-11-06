function store_config_(obj,config_class,force_save,do_not_save,varargin)
% Function stores the configutation class - child of a config_base class
% in single memory place and
% in a special file in the configurations location folder.
%
% if varargin is present, it has to be a cellarray in the form
% {'field_name1',field_value1,'field_name2',field_value2,.... }
%
% in this case, only the fields and values specified in this list are set
% if the class was already stored in configuration. If it was not in the
% configuration, other values for config class are taken fron config_class
% defaults.
%

if isa(config_class,'config_base')
    class_name = config_class.class_name;
elseif(is_string(config_class))
    class_name = config_class;
    config_class = feval(class_name);
else
    error('HERBERT:config_store:invalid_argument',...
        'input for config_store should be either instance of config class or string with a config class name')
end
was_in_memory = isfield(obj.config_storage_,class_name);

if nargin>4 % we need to set some fields before storing the configuration.
    if was_in_memory
        data_to_save = obj.config_storage_.(class_name);
    elseif check_isconfigured(obj,config_class,false)
        data_to_save=obj.get_config(config_class);
    else % defaults from the class
        data_to_save = config_class.get_data_to_store();
    end
    % change only the fields, specified in the varargin
    for i=1:2:numel(varargin)
        data_to_save.(varargin{i})=varargin{i+1};
    end
else % defaults
    data_to_save = config_class.get_data_to_store();
end

data_changed = ~was_in_memory || ...  % if true, second check is not performed
    ~isequal(obj.config_storage_.(class_name),data_to_save);
% change data in memory.
if data_changed
    obj.config_storage_.(class_name)  = data_to_save;
end
if do_not_save
    return;
end

% store changes in file to recover it in a future operations.
if config_class.saveable || force_save
    % avoid saving if stored class is equal to the class
    % already in memory (as it has been already loaded)
    if was_in_memory && ~data_changed && ~force_save
        % if the data to save have not changed, we not saving anything to
        % file
        return;
    end
    obj.save_config(class_name,data_to_save);
end

