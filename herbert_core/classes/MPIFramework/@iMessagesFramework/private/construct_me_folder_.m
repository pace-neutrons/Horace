function obj=construct_me_folder_(obj,new_folder_name)

[remote_config_folder,config_ext] = obj.build_exchange_folder_name(new_folder_name);
obj.mess_exchange_folder_ = fullfile(remote_config_folder,config_ext);
if ~(exist(obj.mess_exchange_folder,'dir') ==7)
    mkdir(obj.mess_exchange_folder);
end


%[existing_config_f,config_f_name] = fileparts(obj.mess_exchange_folder);


existing_config_f= config_store.instance().config_folder;
%config_f_name= config_store.instance().config_folder_name;


if ~strcmp(remote_config_folder,existing_config_f)
    copy_existing_config_to_remote_(existing_config_f,remote_config_folder);
end
