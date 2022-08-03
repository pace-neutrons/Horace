<<<<<<< HEAD
<<<<<<< HEAD
function benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,filename)
%BENCHMARK_COMBINE_SQW Summary of this function goes here
%   Detailed explanation goes here
%% Setup nprocs and other config info with hpc_config() (save intial config details for later)
=======
function benchmark_combine_sqw(cut1,cutN,nProcs,filename)
=======
function benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,filename)
>>>>>>> 8d4db5de5 (updating gen_data functions)
%BENCHMARK_COMBINE_SQW Summary of this function goes here
%   Detailed explanation goes here
<<<<<<< HEAD
%% Setup nprocs and other config info with hpc_config() (save intiial config details for later)
>>>>>>> 4ad9d7cfa (add first benchmarking version)
=======
%% Setup nprocs and other config info with hpc_config() (save intial config details for later)
>>>>>>> 7a8c2792b (Use horace_paths object)

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

<<<<<<< HEAD
<<<<<<< HEAD
[cut1,cutN] = gen_bm_combine_data(nDims,dataSource, dataType, dataNum);
profile on
wout = combine_sqw(cut1, cutN);
prof_results = profile('info');

pths = horace_paths;
prof_folder = fullfile(pths.bm,'bm_combine_sqw');
=======
=======
[cut1,cutN] = gen_bm_combine_data(nDims,dataSource, dataType, dataNum);
>>>>>>> 8d4db5de5 (updating gen_data functions)
profile on
wout = combine_sqw(cut1, cutN);
prof_results = profile('info');
<<<<<<< HEAD
prof_folder = fullfile(fileparts(fileparts(mfilename('fullpath')...
<<<<<<< HEAD
                )),'benchmarking_results');
>>>>>>> 4ad9d7cfa (add first benchmarking version)
=======
                )),'bm_combine_sqw');
>>>>>>> f19dcce9c (switch to using dummy_sqw to generate bm data)
=======

pths = horace_paths;
prof_folder = fullfile(pths.bm,'bm_combine_sqw');
>>>>>>> 7a8c2792b (Use horace_paths object)
dump_profile(prof_results,fullfile(prof_folder,filename));
end

function benchmark_combine_sqw_cleanup(cur_hpc_config)
% Reset hpc configurations
set(hpc_config, cur_hpc_config);
end
