function store_config_info_(obj,info)
% store configuration data necessary to initiate Herbert/Horace mpi
% job on a remote machine.
% Info -- the data describing the job itself.

pc = parallel_config;
remote_folder = pc.shared_folder_on_local;


if isempty(remote_folder) % remote folder located and mounted
    % on the remote system in the same place as the local folder.
    % Store info and do nothing.
    %if isempty(
    target_file = obj.get_par_config_file_name();

else
    target_file = obj.get_par_config_file_name(remote_folder);
    remote_parallel_folder = fileparts(target_file);
    if ~(exist(remote_parallel_folder ,'dir' ) == 7)
        mkdir(remote_parallel_folder )
    end
    remote_config_folder = fileparts(remote_parallel_folder);
    local_config_folder = fileparts(fileparts(obj.get_par_config_file_name));
    copyfile(local_config_folder,remote_config_folder,'f')
    
    % copy all current configurations into remote config folder


end
tf = fileparts(target_file);
if ~(exist(tf,'dir') == 7)
    mkdir(tf);
end
save(target_file,'info');
