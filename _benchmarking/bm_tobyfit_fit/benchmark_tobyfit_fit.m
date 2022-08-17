function benchmark_tobyfit_fit(nDims,dataSource,dataSize,dataSet,nProcs,func_handle,params,filename)
%BENCHMARK_TOBYFIT_FIT This funciton initiates the benchmarks for
%fit()
% This function is used to run all the individual benchamrks in the 3 
% test_tobyfit_fit classes.
% This function generates cuts from sqw or dnd objects and uses the 
% profiler to generate a csv file of timing data.
% There is also the option for a user to run a custom benchmark of
% fit() by calling benchmark_tobyfit_fit() directly
% Inputs:
%
%   nDims       dimensions of the sqw objects to combine: [int: 1,2 or 3]
%   dataSource  filepath to a saved sqw object or emoty string
%   dataSize    size of sqw objects to cut:
%               [char: 'small','medium' or 'large' (10^6,10^7 and 10^8
%               pixels) or an int from 5-9.]
%   dataSet     the size of the array of sqw objects
%               [char: 'small','medium' or 'large'or an int]
%   func_handle the name of the function to fit
%   params      the parameters of the function used in func_handle
%   nProcs      the number of processors the benchmark will run on 
%               [int > 0 for parallel code]
%               [string: "small","medium" or "large" or an array]
%   filename    filepath to where benchmarking data will be saved (.csv file)

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
fit_sqw = tobyfit(sqw_obj);
fit_sqw = fit_sqw.set_local_foreground;
fit_sqw = fit_sqw.set_fun(func_handle,params);
if strcmp(dataSet,'small') == 0
    fit_sqw = fit_sqw.set_bind({2,[2,1]});
end
% fit_sqw = fit_sqw.set_bfun(@testfunc_bkgd,[0,0]);
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