function benchmark_tobyfit_fit(nDims,dataSource,dataSize,dataSet,nProcs,filename) %func_handle,params,
%BENCHMARK_TOBYFIT_FIT Summary of this function goes here
%   Detailed explanation goes here
%% Setup nprocs and other config info with hpc_config() (save intiial config details for later)

hpc = hpc_config();
cur_hpc_config = hpc.get_data_to_store();
addpath(fullfile(horace_root(), '_test', 'test_instrument_classes'));
% remove configurations from memory. Ensure only stored configurations are
% stored
clear config_store;

% % Create cleanup object (*** MUST BE DONE BEFORE ANY CHANGES TO CONFIGURATIONS)
cleanup_obj = onCleanup(@()benchmark_tobyfit_fit_cleanup(cur_hpc_config));

% Set hpc config for benchmarks
if nProcs > 0
%     hpc.parallel_multifit = true;
    hpc.parallel_workers_number = nProcs;
%     warning("HORACE:benchmark_tobyfit_fit:not_implemented",...
%         "tobyfit_parallel does not yet exist, setting nProcs to 0")
else
%     hpc.parallel_multifit = false;
end

% Generat the sqw object for tobyfit
sqw_obj = gen_bm_tobyfit_fit_data(nDims,dataSource,dataSize,dataSet);
nlist=0;
amp = 6000;
fwhh = 0.2;
fit_sqw = tobyfit(sqw_obj);
fit_sqw = fit_sqw.set_local_foreground;
fit_sqw = fit_sqw.set_fun(@slow_func,{[amp, fwhh],@testfunc_nb_sqw,10});
% fit_sqw = fit_sqw.set_fun(@slow_func,{[350,1,100,0.05,0.05,0.05],@gauss2d,10});
if strcmp(dataSet,'small') == 0
    fit_sqw = fit_sqw.set_bind({2,[2,1]});
end
fit_sqw = fit_sqw.set_bfun(@testfunc_bkgd,[0,0]);
fit_sqw = fit_sqw.set_mc_points(2);
fit_sqw = fit_sqw.set_options('listing',nlist);

%% Start profiler
profile on
[wfit_1,fitpar_1]=fit_sqw.fit;
prof_results = profile('info');

pths = horace_paths;
prof_folder = fullfile(pths.bm,'bm_tobyfit_fit');
dump_profile(prof_results,fullfile(prof_folder,filename));
end

function benchmark_tobyfit_fit_cleanup(cur_hpc_config)
% Reset hpc configurations
set(hpc_config, cur_hpc_config);
end