function [remote_job_folder,local_config_folder] = ...
    store_config_info_(obj,info,varargin)
% store configuration data necessary to initiate Herbert/Horace mpi
% job on a remote machine.
% Info -- the data describing the job itself.


[fname,fpath,is_default] = obj.par_config_file(varargin{:});

target_file = fullfile(fpath,fname);
if  ~is_default
    %if isempty(
    remote_exchange_folder = fpath;
    if ~(exist(remote_exchange_folder ,'dir' ) == 7)
        mkdir(remote_exchange_folder )
    end
    remote_config_folder = fileparts(fileparts(remote_exchange_folder));
    local_config_folder  = config_store.instance().config_folder;
    
    copyfile(local_config_folder,remote_config_folder,'f')
    % copy all current configurations into remote config folder
    
end
remote_job_folder = fileparts(target_file);
if ~(exist(remote_job_folder,'dir') == 7)
    mkdir(remote_job_folder);
end

save(target_file,'info');
