function benchmark_gen_sqw(q_range,dataSet,par_file_info,nProcs,filename)%par_file
%BENCHMARK_GEN_SQW This funciton initiates the benchmarks for gen_sqw
%   This function is used to run all the individual benchamrks in the 3 
%   test_gen_sqw classes.
%   The function checks if the benchmarks are to be run in serial or
%   parallel as well as setting sample and detector parameters:
%   efix,emode,alatt,angdeg,u,v,omega,dpsi,gl and gs.
%   A benchmark is run and then saved in a csv file with the name of the
%   benchmark run.
%   There is also the option for a user to run a custom benchmark of
%   gen_sqw by calling the benchmark_gen_sqw() directly.
%

hpc = hpc_config();
cur_hpc_config = hpc.get_data_to_store();
% remove configurations from memory. Ensure only stored configurations are
% stored
clear config_store;

% Set hpc config for benchmarks
if nProcs > 0
%     hpc.parallel_gen_sqw = true;
    hpc.parallel_workers_number = nProcs;
%     warning("HORACE:benchmark_gen_sqw:not_implemented",...
%         "parallel_gen_sqw does not yet exist, setting nProcs to 0")
else
%     hpc.parallel_gen_sqw = false;
end

efix = 787;
emode=1;
alatt=[2.87,2.87,2.87];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,0];
omega=0;dpsi=0;gl=0;gs=0;

% Generate nxspe and detector data

[nxspe_files,psi] = gen_bm_gen_sqw_data(q_range,dataSet,par_file_info,...
    efix,alatt,angdeg,u,v,omega,dpsi,gl,gs);
pths = horace_paths;
gen_folder = fullfile(pths.bm,'bm_gen_sqw');
sqw_file = [gen_folder,filesep,'bm_sqw.sqw'];
%% Start profiler
profile on

gen_sqw(nxspe_files,'',sqw_file,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs);

prof_results = profile('info');
prof_folder = fullfile(pths.bm,'bm_gen_sqw');
dump_profile(prof_results,fullfile(prof_folder,filename));

% % Create cleanup object (*** MUST BE DONE BEFORE ANY CHANGES TO CONFIGURATIONS)
cleanup_obj = onCleanup(@()benchmark_gen_sqw_cleanup(cur_hpc_config,nxspe_files,sqw_file));
end

function benchmark_gen_sqw_cleanup(cur_hpc_config,nxspe_file_list,sqw_file)
% Reset hpc configurations
set(hpc_config,cur_hpc_config);
for i=1:numel(nxspe_file_list)
    delete(nxspe_file_list{i})
end
delete(sqw_file)
end

