function benchmark_gen_sqw(dataSize,dataSet,nProcs,filename)%par_file
%BENCHMARK_GEN_SQW Summary of this function goes here
%   Detailed explanation goes here

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

% Generate spe and par files
efix = 787;
emode=1;
alatt=[2.87,2.87,2.87];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,0];
omega=0;dpsi=0;gl=0;gs=0;
pths = horace_paths;

common_data = fullfile(pths.bm,'common_data');
par_file = fullfile(common_data,'4to1_124.par');
%% Start profiler

[nxspe_files,psi] = gen_bm_gen_sqw_data(dataSize,dataSet);
gen_folder = fullfile(pths.bm,'bm_gen_sqw');
sqw_file = [gen_folder,filesep,'bm_sqw.sqw'];
profile on

gen_sqw(nxspe_files,par_file,sqw_file,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs);

prof_results = profile('info');
prof_folder = fullfile(pths.bm,'bm_gen_sqw');
dump_profile(prof_results,fullfile(prof_folder,filename));

% % Create cleanup object (*** MUST BE DONE BEFORE ANY CHANGES TO CONFIGURATIONS)
cleanup_obj = onCleanup(@()benchmark_gen_sqw_cleanup(cur_hpc_config,nxspe_files));
end

function benchmark_gen_sqw_cleanup(cur_hpc_config,nxspe_file_list)
% Reset hpc configurations
set(hpc_config,cur_hpc_config);
for i=1:numel(nxspe_file_list)
    delete(nxspe_file_list{i})
end
end

