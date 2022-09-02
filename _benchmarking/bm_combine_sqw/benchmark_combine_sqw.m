function benchmark_combine_sqw(nDims,dataInfo,dataSet,nProcs,filename)
%BENCHMARK_COMBINE_SQW This function initiates the benchmarks for
%combine_sqw()
%   This function is used to run all the individual benchamrks in the 3 
%   test_combine_sqw classes.
%   The function checks if the benchmarks are to be run in serial or
%   parallel. It then generates the sqw objects specified.
%   combine_sqw() is run and the benchamrk data saved in a csv file with 
%   the name of the benchmark function run.
%   There is also the option for a user to run a custom benchmark of
%   combine_sqw() by calling the benchmark_combine_sqw() directly.
%
% Inputs:
%
%   nDims       dimensions of the sqw objects to combine: 1,2 or 3
%   dataInfo    size of the original sqw objects to combine:
%               char type: 'small','medium' or 'large' (10^6,10^7 and 10^8
%               pixels), an integer from 6-10 (number of pixels 
%               in base sqw object to generate) or the filepath to an 
%               existing sqw file                    
%   dataSet     the amount of sqw objects to combine:
%               Char: 'small', 'medium' or 'large' (2, 4 and 8 files 
%               respectively) or a numeric amount.
%   nProcs      the number of processors the benchmark will run on
%   filename    filepath to where benchmarking data will be saved (.csv file)
% Custom example:
% >>> benchmark_combine_sqw(2,'saved.sqw','medium',2,'custom.csv')
% >>> benchmark_combine_sqw(2,'small',6,10,2,'custom.csv')
% >>> benchmark_combine_sqw(2,8,6,10,2,'custom.csv')

%% Setup nprocs and other config info with hpc_config() (save intial config details for later)

    hpc = hpc_config();
    cur_hpc_config = hpc.get_data_to_store();
    
    % remove configurations from memory. Ensure only stored configurations are
    % stored
    clear config_store;
    
    % % Create cleanup object (*** MUST BE DONE BEFORE ANY CHANGES TO CONFIGURATIONS)
    cleanup_obj = onCleanup(@()benchmark_combine_sqw_cleanup(cur_hpc_config));
    
    % Set hpc config for benchmarks
    if nProcs > 0
    %     hpc.combine_parallel = true;
        hpc.parallel_workers_number = nProcs;
    else
    %     hpc.combine_parallel=false;
        warning("HORACE:benchmark_combine_sqw:invalid_argument",...
            "nProcs currently only valid for 1, 2 and 4")
    end
    % Generate the needed data for combine_sqw()
    [cut1,cutN] = gen_bm_combine_data(nDims,dataInfo,dataSet);
    % Start the profiler
    profile on
    wout = combine_sqw(cut1, cutN);
    % dump the benchmark info in csv file
    % ocr96: (setup seperate dumps functions for different type of dumps: html, all text(profsave), csv, just bm time...
    prof_results = profile('info');
    pths = horace_paths;
    prof_folder = fullfile(pths.bm,'bm_combine_sqw');
    dump_profile(prof_results,fullfile(prof_folder,filename));
end

function benchmark_combine_sqw_cleanup(cur_hpc_config)
% Reset hpc configurations
set(hpc_config, cur_hpc_config);
end
