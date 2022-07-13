function benchmark_combine_sqw(cut1,cutN,nProcs,filename)
%BENCHMARK_COMBIN_SQW Summary of this function goes here
%   Detailed explanation goes here
%% Setup nprocs and other config info with hpc_config() (save intiial config details for later)

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

profile on
wout = combine_sqw(cut1, cutN);
prof_results = profile('info');
prof_folder = fullfile(fileparts(fileparts(mfilename('fullpath')...
                )),'benchmarking_results');
dump_profile(prof_results,fullfile(prof_folder,filename));
end

function benchmark_combine_sqw_cleanup(cur_hpc_config)
% Reset hpc configurations
set(hpc_config, cur_hpc_config);
end
