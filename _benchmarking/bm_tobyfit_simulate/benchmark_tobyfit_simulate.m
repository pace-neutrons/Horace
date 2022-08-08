function benchmark_tobyfit_simulate(nDims,dataSource,dataSize,dataSet,nProcs,func_handle,params,filename)
%BENCHMARK_TOBYFIT_SIMULATE Summary of this function goes here
%   Detailed explanation goes here
%% Setup nprocs and other config info with hpc_config() (save intiial config details for later)

hpc = hpc_config();
cur_hpc_config = hpc.get_data_to_store();
addpath(fullfile(horace_root(), '_test', 'test_instrument_classes'));
% remove configurations from memory. Ensure only stored configurations are
% stored
clear config_store;

% % Create cleanup object (*** MUST BE DONE BEFORE ANY CHANGES TO CONFIGURATIONS)
cleanup_obj = onCleanup(@()benchmark_tobyfit_simulate_cleanup(cur_hpc_config));

% Set hpc config for benchmarks
if nProcs > 0
%     hpc.parallel_multifit = true;
    hpc.parallel_workers_number = nProcs;
%     warning("HORACE:benchmark_tobyfit_simulate:not_implemented",...
%         "tobyfit_parallel_simulate does not yet exist, setting nProcs to 0")
%     nProcs=0;
else
%     hpc.tobyfit_simulate_parallel=false
end

sqw_obj = gen_bm_tobyfit_simulate_data(nDims,dataSource,dataSize,dataSet);
nlist=0;
sim_sqw=tobyfit(sqw_obj);
sim_sqw = sim_sqw.set_local_foreground;
sim_sqw = sim_sqw.set_fun(func_handle,params);
% if strcmp(dataSet,'small') == 0
%     sim_sqw = sim_sqw.set_bind({2,[2,1]});
% end
% w_sqw = w_sqw.set_bfun(@testfunc_bkgd,[0,0]);
sim_sqw = sim_sqw.set_mc_points(2);
sim_sqw = sim_sqw.set_options('listing',nlist);
%% Start profiler
profile on
[wsim_1,simpar_1]=sim_sqw.simulate;

prof_results = profile('info');
pths = horace_paths;
prof_folder = fullfile(pths.bm,'bm_tobyfit_simulate');
dump_profile(prof_results,fullfile(prof_folder,filename));
end

function benchmark_tobyfit_simulate_cleanup(cur_hpc_config)
% Reset hpc configurations
set(hpc_config, cur_hpc_config);
end

