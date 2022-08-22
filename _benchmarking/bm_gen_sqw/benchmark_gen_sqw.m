function benchmark_gen_sqw(dataSize,dataSet,par_file_data,nProcs,filename)
%BENCHMARK_GEN_SQW This funciton initiates the benchmarks for gen_sqw()
%   This function is used to run all the individual benchamrks in the 3 
%   test_gen_sqw classes.
%   The function checks if the benchmarks are to be run in serial or
%   parallel as well as setting sample and detector parameters:
%   efix,emode,alatt,angdeg,u,v,omega,dpsi,gl and gs.
%   A benchmark is run and then saved in a csv file with the name of the
%   benchmark run.
%   There is also the option for a user to run a custom benchmark of
%   gen_sqw() by calling the benchmark_gen_sqw() directly.
%
% Inputs:
%   - dataSize: the size and number of the energy bins.
%             'small', 'medium' or 'large', or an integer: 0:X:efix
%   - dataSet: the amount of nxspe files to gnerate.
%             'small', 'medium' or 'large' (12, 23 and 46 files respectively)
%              or an integer amount of files (default psi angle is 90, so 90/X 
%              will determine the number of files generated i.e. 10 will 
%              generate 9 files).
%   - par_file_data: number of detector pixels. 'small','medium', or 'large';
%              Corresponding to MAPS, MERLIN and LET. 
%              If a custom detector is wanted, input must be the number of
%              detector pixels
%   - nProcs: the number of processors the benchmark will run on
%   - filename: filepath to where benchmarking data will be saved (.csv file)
% Custom example:
% >>> benchmark_gen_sqw('small',small',36864,1,'custom.csv')
% >>> benchmark_gen_sqw(16,10,36864,4,'custom.csv')


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
    [nxspe_files,psi] = gen_bm_gen_sqw_data(dataSize,dataSet,par_file_data,...
        efix);
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

