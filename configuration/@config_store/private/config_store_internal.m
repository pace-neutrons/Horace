function config_store_internal(this,config_class,force_save)
% Function stores the configutation class - child of a config_base class
% in single memory place and in if requested
% into special file in the configurations location folder.
%
%

%
class_name = config_class.class_name;

if config_class.saveable || force_save
    % avoid saving if stored class is equal to the class
    % already in memory (as it has been already loaded)
    
    if isfield(this.config_storage_,class_name) && ~force_save
        if this.config_storage_.(class_name) == config_class
            return;
        end
    end
    filename = fullfile(this.config_folder,[class_name,'.mat']);
    [ok,mess]=save_config(filename,config_class);
    if ~ok
        error('CONFIG_STORE:store_config',mess);
    end
end
% store everything in memory too.
this.config_storage_.(class_name)  = config_class;


end

