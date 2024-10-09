function validate_horace_cleanup(cur_horace_config, cur_hpc_config, ...
    cur_par_config, test_folders, initial_warn_state)
% Function is used within Horace testing scripts
%
% Reset the configurations, and remove unit test folders from the path

set(hor_config, cur_horace_config);
set(hpc_config, cur_hpc_config);
set(parallel_config, cur_par_config);

warning('off',  'all'); % avoid warning on deleting non-existent path

% Clear up the test folders, previously placed on the path
for i = 1:numel(test_folders)
    rmpath(test_folders{i});
end

warning(initial_warn_state);
end
