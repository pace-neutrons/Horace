function benchmark_sqw_eval(nDims,dataSource,dataSize,dataSet,objType,func_handle,params,nProcs,filename)
%BENCHMARK_SQW_EVAL This funciton initiates the benchmarks for
%sqw_eval()
% This function is used to run all the individual benchamrks in the 3 
% test_sqw_eval classes.
% This function generates cuts from sqw or dnd objects and uses the 
% profiler to generate a csv file of timing data.
% There is also the option for a user to run a custom benchmark of
% sqw_eval() by calling benchmark_sqw_eval() directly
% Inputs:
%
%   nDims       dimensions of the sqw objects to combine: [int: 1,2 or 3]
%   dataSource  filepath to a saved sqw object or empty string
%   dataSize    size of sqw objects to cut:
%               [char: 'small','medium' or 'large' (10^7,10^8 and 10^9
%               pixels) or an int from 6-10]
%   dataSet     the size of the array of sqw objects
%               [char: 'small','medium' or 'large' or an int]
%   objType    type of object [string: "sqw" or "dnd"]
%   func_handle the name of the function to evaluate
%   params      the parameters of the function used in func_handle
%   nProcs      the number of processors the benchmark will run on 
%               [int > 0 for parallel code]
%               [string: "small","medium" or "large" or an array]
%   filename    filepath to where benchmarking data will be saved (.csv file)
% Custom example:
% >>> benchmark_sqw_eval(1,'',6,'small',"dnd",@slow_func,{[250 0 2.4 10 5],@demo_FM_spinwaves,10^0},1,'custom.csv')
% >>> benchmark_sqw_eval(1,'saved.sqw',6,7,"sqw",@slow_func,{[250 0 2.4 10 5],@demo_FM_spinwaves,10^0},1,'custom.csv')

%% Setup nprocs and other config info with hpc_config() (save intiial config details for later)

hpc = hpc_config();
cur_hpc_config = hpc.get_data_to_store();

% remove configurations from memory. Ensure only stored configurations are
% stored
clear config_store;

% % Create cleanup object (*** MUST BE DONE BEFORE ANY CHANGES TO CONFIGURATIONS)
cleanup_obj = onCleanup(@()benchmark_sqw_eval_cleanup(cur_hpc_config));

% Set hpc config for benchmarks
if nProcs > 0
%     hpc.sqw_eval_parallel = true for future implementation
     hpc.parallel_workers_number = nProcs;
%     warning("HORACE:benchmark_sqw_eval:not_implemented",...
%         "sqw_eval_parallel does not yet exist, setting nProcs to 0")
else
%     hpc.sqw_eval_parallel=false
end

%% Start profiler
sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataSize,dataSet,objType);
profile on
w_sqw=sqw_eval(sqw_dnd_obj,func_handle,params);
prof_results = profile('info');
pths = horace_paths;
prof_folder = fullfile(pths.bm,'bm_sqw_eval');
dump_profile(prof_results,fullfile(prof_folder,filename));
end

function benchmark_sqw_eval_cleanup(cur_hpc_config)
% Reset hpc configurations
set(hpc_config, cur_hpc_config);
end