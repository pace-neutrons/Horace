function store_config_info_(obj,info)
% store configuration data necessary to initiate Herbert/Horace mpi
% job on a remote machine.
% Info -- the data describing the job itself.

pc = parallel_config;
remote_folder = pc.remote_folder_on_local;


if isempty(remote_folder) % remote folder located and mounted
    % on the remote system in the same place as the local folder.
    % Store info and do nothing.
    %if isempty(
    target_file = obj.get_config_file_name();

else
    if ~exist(remote_folder,'dir') == 7
        mkdir(remote_folder);
    end
    target_file = obj.get_config_file_name(remote_folder);
    remote_config_folder = fileparts(target_file);
    local_config_folder = fileparts(obj.get_config_file_name);
    copyfile(local_config_folder,remote_config_folder,'f')
    
    % copy all current configurations into remote config folder


end
save(target_file,'info');
