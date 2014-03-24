function config_store_internal(this,config_class,force_save,varargin)
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
%
% $Revision: 278 $ ($Date: 2013-11-01 20:07:58 +0000 (Fri, 01 Nov 2013) $)
%
class_name = config_class.class_name;
if nargin>3 % we need to set some fields before storing the configuration. 
    if isfield(this.config_storage_,class_name)
        data_to_save = this.config_storage_.(class_name);
    elseif check_isconfigured(this,config_class,false)
        data_to_save=this.get_config(config_class);
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

if config_class.saveable || force_save
    % avoid saving if stored class is equal to the class
    % already in memory (as it has been already loaded)
    
    if isfield(this.config_storage_,class_name) && ~force_save
        % if the data to save have not changed, we not saving anything to
        % file
        if isequal(this.config_storage_.(class_name),data_to_save);
            % there is subtle problem if data have never been stored to
            % file
            return;
        end
    end
    filename = fullfile(this.config_folder,[class_name,'.mat']);
    [ok,mess]=save_config(filename,data_to_save);
    if ~ok
        error('CONFIG_STORE:store_config',mess);
    end
end
% store data in memory too.
this.config_storage_.(class_name)  = data_to_save;



