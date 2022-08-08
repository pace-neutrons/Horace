function benchmark_func_eval(nDims,dataSource,dataSize,dataSet,func_handle,params,nProcs,filename)
%BENCHMARK_FUNC_EVAL Summary of this function goes here
%   Detailed explanation goes here
%% Setup nprocs and other config info with hpc_config() (save intiial config details for later)

hpc = hpc_config();
cur_hpc_config = hpc.get_data_to_store();

% remove configurations from memory. Ensure only stored configurations are
% stored
clear config_store;

% % Create cleanup object (*** MUST BE DONE BEFORE ANY CHANGES TO CONFIGURATIONS)
cleanup_obj = onCleanup(@()benchmark_func_eval_cleanup(cur_hpc_config));

% Set hpc config for benchmarks
if nProcs > 0
%     hpc.func_eval_parallel = true for future implementation
    hpc.parallel_workers_number = nProcs;
%     warning("HORACE:benchmark_func_eval:not_implemented",...
%         "func_eval_parallel does not yet exist, setting nProcs to 0")
else
%     hpc.func_eval_parallel=false
end

%% Start profiler

sqw_obj=gen_bm_func_eval_data(nDims,dataSource,dataSize,dataSet);
profile on
w_sqw=func_eval(sqw_obj,func_handle,params);
prof_results = profile('info');
pths = horace_paths;
prof_folder = fullfile(pths.bm,'bm_func_eval');
dump_profile(prof_results,fullfile(prof_folder,filename));
end

function benchmark_func_eval_cleanup(cur_hpc_config)
% Reset hpc configurations
set(hpc_config, cur_hpc_config);
end