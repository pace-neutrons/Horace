function benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,filename)
%BENCHMARK_COMBINE_SQW Summary of this function goes here
%   Detailed explanation goes here
%% Setup nprocs and other config info with hpc_config() (save intial config details for later)

hpc = hpc_config();
cur_hpc_config = hpc.get_data_to_store();

% remove configurations from memory. Ensure only stored configurations are
% stored
clear config_store;

% % Create cleanup object (*** MUST BE DONE BEFORE ANY CHANGES TO CONFIGURATIONS)
cleanup_obj = onCleanup(@()benchmark_combine_sqw_cleanup(cur_hpc_config));

% Set hpc config for benchmarks
if nProcs > 1
%     hpc.combine_parallel = true;
    hpc.parallel_workers_number = nProcs;
elseif nProcs==1
%     hpc.combine_parallel=false
else
    warning("HORACE:benchmark_combine_sqw:invalid_argument",...
        "nProcs currently only valid for 1, 2 and 4")
end

[cut1,cutN] = gen_bm_combine_data(nDims,dataSource, dataType, dataNum);
profile on
wout = combine_sqw(cut1, cutN);
prof_results = profile('info');

pths = horace_paths;
prof_folder = fullfile(pths.bm,'bm_combine_sqw');
dump_profile(prof_results,fullfile(prof_folder,filename));
end

function benchmark_combine_sqw_cleanup(cur_hpc_config)
% Reset hpc configurations
set(hpc_config, cur_hpc_config);
end
