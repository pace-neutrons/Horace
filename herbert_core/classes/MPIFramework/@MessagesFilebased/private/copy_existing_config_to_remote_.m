function copy_existing_config_to_remote_(current_config_f,remote_config_f)
% copy configuration data necessary to initiate Herbert/Horace
% on a remote machine.
%
if ~(is_folder(remote_config_f))
    mkdir(remote_config_f);
end
try
    copyfile(current_config_f,remote_config_f,'f');
catch ME
    warning('HERBERT:MessagesFilebased:runtime_error',...
        ' Error in copy_existing contig_to_remote:\n %s',...
        evalc('disp(ME)'));
end

