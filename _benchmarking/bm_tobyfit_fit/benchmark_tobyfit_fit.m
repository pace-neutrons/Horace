function benchmark_tobyfit_fit(nDims,dataInfo,dataSet,nProcs,func_handle,params,filename)
%BENCHMARK_TOBYFIT_FIT This function initiates the benchmarks for
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
%   dataInfo    size of the original sqw objects to combine:
%               char type: 'small','medium' or 'large' (10^6,10^7 and 10^8
%               pixels), an integer from 6-10 (number of pixels
%               in base sqw object to generate) or the filepath to an
%               existing sqw file
%   dataSet     the size of the array of sqw objects
%               [char: 'small','medium' or 'large'or an int]
%   func_handle the name of the function to fit
%   params      the parameters of the function used in func_handle
%   nProcs      the number of processors the benchmark will run on
%               [int > 0 for parallel code]
%               [string: "small","medium" or "large" or an array]
%   filename    filepath to where benchmarking data will be saved (.csv file)
% Custom example:
% >>> benchmark_tobyfit_fit(1,'saved.sqw','',3,4,@slow_func,{[250 0 2.4 10 5],@demo_FM_spinwaves,10^0},'custom.csv')
% >>> benchmark_tobyfit_fit(1,'',9,3,4,@slow_func,{[250 0 2.4 10 5],@demo_FM_spinwaves,10^0},'custom.csv')

%% Setup nprocs and other config info with hpc_config() (save intiial config details for later)
    do_profile = exist('filename', 'var');

    hpc = hpc_config();
    cur_hpc_config = hpc.get_data_to_store();
    pths = horace_paths;
    addpath(fullfile(pths.test, 'test_instrument_classes'));
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

    % Generate the sqw object for tobyfit
    sqw_obj = gen_bm_tobyfit_fit_data(nDims,dataInfo,dataSet);
    fit_sqw = tobyfit(sqw_obj);
    fit_sqw = fit_sqw.set_local_foreground;
    fit_sqw = fit_sqw.set_fun(func_handle,params);
    fit_sqw = fit_sqw.set_mc_points(2);
    fit_sqw = fit_sqw.set_options('listing',0);

    % Start the profiler
    if do_profile
        profile('on')
    end

    [wfit_1,fitpar_1]=fit_sqw.fit();

    if do_profile
        prof_results = profile('info');
        % dump the benchmark info in csv file
        % ocr96: (setup seperate dumps functions for different type of dumps: html, all text(profsave), csv, just bm time...
        prof_folder = fullfile(pths.bm,'bm_tobyfit_fit');
        dump_profile(prof_results,fullfile(prof_folder,filename));
    end
end

function benchmark_tobyfit_fit_cleanup(cur_hpc_config)
    % Reset hpc configurations
    set(hpc_config, cur_hpc_config);
end
