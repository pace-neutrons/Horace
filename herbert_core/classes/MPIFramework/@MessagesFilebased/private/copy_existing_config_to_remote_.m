function copy_existing_config_to_remote_(current_config_f,remote_config_f)
% copy configuration data necessary to initiate Herbert/Horace
% on a remote machine.
%
    if ~(is_folder(remote_config_f))
        mkdir(remote_config_f);
    end
    copyfile(current_config_f,remote_config_f,'f');
end