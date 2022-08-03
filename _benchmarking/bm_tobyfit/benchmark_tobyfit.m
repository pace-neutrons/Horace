<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
function benchmark_tobyfit(nDims,dataSource,dataSize,dataSet,nProcs,filename)
=======
function benchmark_tobyfit(sqw_obj,nProcs,filename)
>>>>>>> 7e6efa9a0 (adding tobyfit benchmarks)
=======
function benchmark_tobyfit(nDims,dataSource,dataType,dataNum,nProcs,filename)
>>>>>>> d26fc9d4c (getting rid of duplicate code)
=======
function benchmark_tobyfit(nDims,dataSource,dataSize,dataSet,nProcs,filename)
>>>>>>> ab0cb176e (making dataSize and dataSource class Properties)
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
%     hpc.tobyfit_parallel = true for future implementation
%     hpc.parallel_workers_number = nProcs;
    warning("HORACE:benchmark_tobyfit:not_implemented",...
        "tobyfit_parallel does not yet exist, setting nProcs to 0")
    nProcs=0;
else
%     hpc.tobyfit_parallel=false
end

%% Start profiler
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataSize,dataSet);
=======
>>>>>>> 7e6efa9a0 (adding tobyfit benchmarks)
=======
sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
>>>>>>> d26fc9d4c (getting rid of duplicate code)
=======
sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataSize,dataSet);
>>>>>>> ab0cb176e (making dataSize and dataSource class Properties)
efix = 50;
instrument = let_instrument_obj_for_tests(efix, 280, 140, 20, 2, 2);
sqw_obj = set_instrument(sqw_obj, instrument);

profile on
w_sqw=tobyfit(sqw_obj);
prof_results = profile('info');
<<<<<<< HEAD
<<<<<<< HEAD

pths = horace_paths;
prof_folder = fullfile(pths.bm,'bm_tobyfit');
=======
prof_folder = fullfile(fileparts(fileparts(mfilename('fullpath')...
                )),'bm_tobyfit');
>>>>>>> 7e6efa9a0 (adding tobyfit benchmarks)
=======

pths = horace_paths;
prof_folder = fullfile(pths.bm,'bm_tobyfit');
>>>>>>> 7a8c2792b (Use horace_paths object)
dump_profile(prof_results,fullfile(prof_folder,filename));
end

function benchmark_tobyfit_cleanup(cur_hpc_config)
% Reset hpc configurations
set(hpc_config, cur_hpc_config);
end