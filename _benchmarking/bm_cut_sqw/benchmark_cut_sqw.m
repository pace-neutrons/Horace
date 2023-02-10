function benchmark_cut_sqw(nDims,dataInfo,objType,nProcs,eRange,contiguous,filename)
%BENCHMARK_CUT_SQW This function initiates the benchmarks for
%cut_sqw()
% This function is used to run all the individual benchmarks in the 3
% test_cut_sqw classes.
% This function generates cuts from sqw or dnd objects and uses the
% profiler to generate a csv file of timing data.
% There is also the option for a user to run a custom benchmark of
% cut_sqw() by calling benchmark_cut_sqw() directly.
% Inputs:
%
%   nDims       dimensions of the sqw objects to combine: [int: 1,2 or 3]
%   dataInfo    details of sqw object to cut:
%               [char: 'small','medium' or 'large' (10^7,10^8 and 10^9
%               pixels), an int from 6-10 or a filepath to existing sqw
%               file]
%   objType     the type of object to cut [string: "sqw" or "dnd"]
%   nProcs      the number of processors the benchmark will run on
%               [int > 0 for parallel code]
%   eRange      the binning along the energy axis: see p4_bin in "help sqw/cut"
%               [string: "small","medium" or "large" or an array]
%   contiguous  make 4 contigous cuts of the same sqw object.
%               boolean: true or false
%   filename    filepath to where benchmarking data will be saved (.csv file)
% Custom example:
% >>> benchmark_cut_sqw(1,6,"sqw",1,"small",false,'custom.csv')
% >>> benchmark_cut_sqw(1,'large',"sqw",1,[0,175],false,'custom.csv')
% >>> benchmark_cut_sqw(1,'saved.sqw',"sqw",1,[0,175],false,'custom.csv')

%% Setup nprocs and other config info with hpc_config() (save initial config details for later)
    do_profile = exist('filename', 'var');

    hpc = hpc_config();
    cur_hpc_config = hpc.get_data_to_store();
    % remove configurations from memory. Ensure only stored configuration  ions are
    % stored
    clear config_store;

    % % Create cleanup object (*** MUST BE DONE BEFORE ANY CHANGES TO CONFIGURATIONS)
    cleanup_obj = onCleanup(@()benchmark_cut_sqw_cleanup(cur_hpc_config));

    % Set hpc config for benchmarks
    if nProcs > 0
    %     hpc.cut_parallel = true for future implementation
        hpc.parallel_workers_number = nProcs;
    %     warning("HORACE:benchmark_cut_sqw:not_implemented",...
    %         "cut_parallel does not yet exist, setting nProcs to 0")
    else
    %     hpc.cut_parallel=false
    end

    %% set projection and binning info, start profiler and call cut_sqw

    proj.u=[1,0,0];
    proj.v=[0,1,0];
    proj.type='rrr';

    %Set pixel bins
    switch nDims
        case 1
            p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.5,0.5];
        case 2
            p1_bin=[-3,0.05,3];p2_bin=[-3,0];p3_bin=[-0.5,0.5];
        case 3
            p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-1,1];
        otherwise
            error("HORACE:benchmark_cut_sqw:invalid_argument",...
                "nDims is the dimensions of the cut: must be 1, 2 or 3")
    end

    % Set energy bins
    if isstring(eRange) || ischar(eRange)
        switch nDims
          case 1
            switch eRange
              case "large"
                p4_bin=[0,787];
              case "medium"
                p4_bin=[0,350];
              case  "small"
                p4_bin=[0,175];
              otherwise
                error("HORACE:benchmark_cut_sqw:invalid_argument",...
                      "if using a string for eRange, must be either ""small"", ""medium"" or ""large""")
            end
          case {2, 3}
            switch eRange
              case "large"
                p4_bin=[0,16,787];
              case "medium"
                p4_bin=[0,16,350];
              case "small"
                p4_bin=[0,16,175];
              otherwise
                error("HORACE:benchmark_cut_sqw:invalid_argument",...
                      "if using a string for eRange, must be either ""small"", ""medium"" or ""large""")
            end

        end

    elseif isnumeric(eRange)
        switch nDims
          case 1
            switch numel(eRange)
              case {2, 4}
                p4_bin = double(eRange);
              otherwise
                error("HORACE:benchmark_cut_sqw:invalid_argument",...
                      "if using an array of doubles for eRange, length of the" + ...
                      " array must be 2 and 4 for 1D cuts and 1 or 3 for 2-3D " + ...
                      "cuts, see help sqw/cut for more details")
            end
          case {2, 3}
            switch numel(eRange)
              case {1, 3}
                p4_bin = double(eRange);
              otherwise
                error("HORACE:benchmark_cut_sqw:invalid_argument",...
                      "if using an array of doubles for eRange, length of the" + ...
                      " array must be 2 and 4 for 1D cuts and 1 or 3 for 2-3D " + ...
                      "cuts, see help sqw/cut for more details")

            end
        end
    else
        error("HORACE:benchmark_cut_sqw:invalid_argument",...
              "eRange must be either an array of doubles or a string")
    end

    % Check if the "contiguous", has been set to true (will do 4 contiguous
    % cuts)
    dataSource = gen_bm_cut_data(dataInfo);

    % Start the profiler
    if do_profile
        profile('on')
    end

    if contiguous
        switch objType
            case "sqw"
                for j=0:4
                    p1_bin = [j-3,0.5,j];
                    sqw_cut = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
                end
            case "dnd"
                for j=0:4
                    p1_bin = [j-3,0.5,j];
                    dnd_cut = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin, '-nopix');
                end
            otherwise
                error("HORACE:benchmark_cut_sqw:invalid_argument",...
                    "objType must be sqw or dnd")
        end

    else
        switch objType
            case "sqw"
                sqw_cut = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
            case "dnd"
                dnd_cut = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin, '-nopix');
            otherwise
                error("HORACE:benchmark_cut_sqw:invalid_argument",...
                    "objType must be sqw or dnd")
        end
    end

    if do_profile
        % dump the benchmark info in csv file
        prof_result = profile('info');
        pths = horace_paths;
        prof_folder = fullfile(pths.bm,'bm_cut_sqw');
        dump_profile(prof_result,fullfile(prof_folder,filename));
    end
end

function benchmark_cut_sqw_cleanup(cur_hpc_config)
    % Reset hpc configurations
    set(hpc_config, cur_hpc_config);
end

