function benchmark_func_eval(nDims,dataInfo,dataSet,func_handle,params,nProcs,filename)
%BENCHMARK_FUNC_EVAL This function initiates the benchmarks for
%func_eval()
% This function is used to run all the individual benchamrks in the 3 
% test_func_eval classes.
% This function generates cuts from sqw and uses the profiler to generate 
% a csv file of timing data.
% There is also the option for a user to run a custom benchmark of
% func_eval() by calling benchmark_func_eval() directly
% Inputs:
%
%   nDims       dimensions of the sqw objects to combine: [int: 1,2 or 3]
%   dataInfo    size of the original sqw objects to combine:
%               char type: 'small','medium' or 'large' (10^6,10^7 and 10^8
%               pixels), an integer from 6-10 (number of pixels 
%               in base sqw object to generate) or the filepath to an 
%               existing sqw file
%   dataSet     the size of the array of sqw objects
%               [char: 'small','medium' or 'large'or an int]
%   func_handle the name of the function to evaluate
%   params      the parameters of the function used in func_handle
%   nProcs      the number of processors the benchmark will run on 
%               [int > 0 for parallel code]
%               [string: "small","medium" or "large" or an array]
%   filename    filepath to where benchmarking data will be saved (.csv file)
% Custom example:
% >>> benchmark_func_eval(1,6,'small',@slow_func,{[175,1,0.05],@gauss,10^0},1,'custom.csv')
% >>> benchmark_func_eval(1,'saved.sqw','7',@slow_func,{[175,1,0.05],@gauss,10^0},1,'custom.csv')
% >>> benchmark_func_eval(1,'medium','7',@slow_func,{[175,1,0.05],@gauss,10^0},1,'custom.csv')

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
    
    % Start the profiler
    
    sqw_obj=gen_bm_func_eval_data(nDims,dataInfo,dataSet);
    profile on
    w_sqw=func_eval(sqw_obj,func_handle,params);
    % dump the benchmark info in csv file
    % ocr96: (setup seperate dumps functions for different type of dumps: html, all text(profsave), csv, just bm time...
    prof_results = profile('info');
    pths = horace_paths;
    prof_folder = fullfile(pths.bm,'bm_func_eval');
    dump_profile(prof_results,fullfile(prof_folder,filename));
end

function benchmark_func_eval_cleanup(cur_hpc_config)
    % Reset hpc configurations
    set(hpc_config, cur_hpc_config);
end