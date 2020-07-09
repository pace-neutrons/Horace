function [new_config, old_parallel_conf] = set_local_parallel_config()
% Set the config directories for the parallel framework
%
% This function is useful for if you're running the same tests in parallel on
% the same machine (e.g. on a build server), it avoids IO errors when separate
% processes attempt to read/write the same config/temporary files.
%
% Output:
% -------
%   new_config      The new parallel_config object
%   old_config      The old parallel_config data. This can be used to restore
%                   the settings to the previous state.
%
SHARED_LOCAL_DIR = fullfile(tmp_dir());
SHARED_REMOTE_DIR = fullfile(tmp_dir());

pc = parallel_config;
old_parallel_conf = pc.get_data_to_store();

new_config = pc;
new_config.shared_folder_on_local = SHARED_LOCAL_DIR;
new_config.shared_folder_on_remote = SHARED_REMOTE_DIR;
