function benchmark_tobyfit(nDims,dataSource,dataSize,dataSet,nProcs,filename)
%BENCHMARK_TOBYFIT Summary of this function goes here
%   Detailed explanation goes here
%% Setup nprocs and other config info with hpc_config() (save intiial config details for later)

hpc = hpc_config();
cur_hpc_config = hpc.get_data_to_store();
addpath(fullfile(horace_root(), '_test', 'test_instrument_classes'));
% remove configurations from memory. Ensure only stored configurations are
% stored
clear config_store;

% % Create cleanup object (*** MUST BE DONE BEFORE ANY CHANGES TO CONFIGURATIONS)
cleanup_obj = onCleanup(@()benchmark_tobyfit_cleanup(cur_hpc_config));

% Set hpc config for benchmarks
if nProcs > 1
%     hpc.func_eval_parallel = true for future implementation
%     hpc.parallel_workers_number = nProcs;
    warning("HORACE:benchmark_tobyfit:not_implemented",...
        "tobyfit_parallel does not yet exist, setting nProcs to 0")
    nProcs=0;
else
%     hpc.tobyfit_parallel=false
end

%% Start profiler
sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataSize,dataSet);
efix = 50;
instrument = let_instrument_obj_for_tests(efix, 280, 140, 20, 2, 2);
sqw_obj = set_instrument(sqw_obj, instrument);

profile on
w_sqw=tobyfit(sqw_obj);
prof_results = profile('info');

pths = horace_paths;
prof_folder = fullfile(pths.bm,'bm_tobyfit');
dump_profile(prof_results,fullfile(prof_folder,filename));
end

function benchmark_tobyfit_cleanup(cur_hpc_config)
% Reset hpc configurations
set(hpc_config, cur_hpc_config);
end