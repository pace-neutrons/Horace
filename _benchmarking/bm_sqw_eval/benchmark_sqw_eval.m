function benchmark_sqw_eval(win,sqw_func,params,nProcs,filename)
%BENCHMARK_SQW_EVAL Summary of this function goes here
%   Detailed explanation goes here

%% Setup nprocs and other config info with hpc_config() (save intiial config details for later)

hpc = hpc_config();
cur_hpc_config = hpc.get_data_to_store();

% remove configurations from memory. Ensure only stored configurations are
% stored
clear config_store;

% % Create cleanup object (*** MUST BE DONE BEFORE ANY CHANGES TO CONFIGURATIONS)
cleanup_obj = onCleanup(@()benchmark_sqw_eval_cleanup(cur_hpc_config));

% Set hpc config for benchmarks
if nProcs > 1
%     hpc.sqw_eval_parallel = true for future implementation
%      hpc.parallel_workers_number = nProcs;
    warning("HORACE:benchmark_sqw_eval:not_implemented",...
        "sqw_eval_parallel does not yet exist, setting nProcs to 0")
    nProcs=0;
else
%     hpc.sqw_eval_parallel=false
end

%% Start profiler
profile on
w_sqw=sqw_eval(win,sqw_func,params);
prof_results = profile('info');
prof_folder = fullfile(fileparts(fileparts(mfilename('fullpath')...
                )),'benchmarking_results');
dump_profile(prof_results,fullfile(prof_folder,filename));
end

function benchmark_sqw_eval_cleanup(cur_hpc_config)
% Reset hpc configurations
set(hpc_config, cur_hpc_config);
end