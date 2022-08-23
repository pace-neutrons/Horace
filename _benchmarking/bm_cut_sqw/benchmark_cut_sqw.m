function benchmark_cut_sqw(nDims,dataFile,dataSize,objType,nProcs,eRange,filename,contiguous)
%BENCHMARK_CUT_SQW This funciton initiates the benchmarks for
%cut_sqw()
% This function is used to run all the individual benchamrks in the 3 
% test_cut_sqw classes.
% This function generates cuts from sqw or dnd objects and uses the 
% profiler to generate a csv file of timing data.
% There is also the option for a user to run a custom benchmark of
% cut_sqw() by calling benchmark_cut_sqw() directly.
% Inputs:
%
%   nDims       dimensions of the sqw objects to combine: [int: 1,2 or 3]
%   dataFile    filepath to a saved sqw object or emoty string
%   dataSize    size of sqw objects to cut:
%               [char: 'small','medium' or 'large' (10^7,10^8 and 10^9
%               pixels) or an int from 6-10]
%   objType     the type of object to cut [string: "sqw" or "dnd"]
%   nProcs      the number of processors the benchmark will run on 
%               [int > 0 for parallel code]
%   eRange      the binning along the energy axis: see p4_bin in "help sqw/cut"
%               [string: "small","medium" or "large" or an array]
%   filename    filepath to where benchmarking data will be saved (.csv file)
%   contiguous  make 4 contigous cuts of the same sqw object.
%               boolean: true or false
% Custom example:
% >>> benchmark_cut_sqw(1,'',6,"sqw",1,"small",'custom.csv',false)
% >>> benchmark_cut_sqw(1,'',6,"sqw",1,[0,175],'custom.csv',false)

%% Setup nprocs and other config info with hpc_config() (save intiial config details for later)

hpc = hpc_config();
cur_hpc_config = hpc.get_data_to_store();
% remove configurations from memory. Ensure only stored configurat  ions are
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

proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';
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
if isa(eRange,'string')
    switch true
        case eRange == "large" && nDims == 1
            p4_bin=[0,787];
        case eRange == "medium" && nDims == 1
            p4_bin=[0,350];
        case eRange == "small" && nDims == 1
            p4_bin=[0,175];
        case eRange == "large" && (nDims == 2 || nDims == 3)
            p4_bin=[0,16,787];
        case eRange == "medium" && (nDims == 2 || nDims == 3)
            p4_bin=[0,16,350];
        case eRange == "small" && (nDims == 2 || nDims == 3)
            p4_bin=[0,16,175];
        otherwise
            error("HORACE:benchmark_cut_sqw:invalid_argument",...
                "if using a string for eRange, must be either ""small"", ""medium"" or ""large""")
    end
elseif isa(eRange,'double')
    disp(numel(eRange))
    switch true
        case (numel(eRange) == 2 || numel(eRange) == 4) && nDims == 1
            p4_bin = eRange;
        case (numel(eRange) == 1 || numel(eRange) == 3) && (nDims == 2 || nDims == 3)
            p4_bin = eRange;
        otherwise
            error("HORACE:benchmark_cut_sqw:invalid_argument",...
                "if using an array of doubles for eRange, length of the" + ...
                " array must be 2 and 4 for 1D cuts and 1 or 3 for 2-3D " + ...
                "cuts, see help sqw/cut for more details")
    end
else
    error("HORACE:benchmark_cut_sqw:invalid_argument",...
                "eRange must be either an array of doubles or a string")
end

% Check if the "contiguous", has been set to true (will do 4 contiguous
% cuts)
dataSource = gen_bm_cut_data(dataFile,dataSize);
profile on
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
%             sqw_obj=sqw(dataSource);
%             disp("Original sqw has: " + sqw_obj.npixels + " pixels")
        case "dnd"
            dnd_cut = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin, '-nopix');
        otherwise
            error("HORACE:benchmark_cut_sqw:invalid_argument",...
                "objType must be sqw or dnd")
    end
end

%% dump benchmark info (setup seperate dumps function for differnet type of dumps: html, all text(profsave), csv, just bm time...
prof_result = profile('info');
pths = horace_paths;
prof_folder = fullfile(pths.bm,'bm_cut_sqw');
dump_profile(prof_result,fullfile(prof_folder,filename));

end

function benchmark_cut_sqw_cleanup(cur_hpc_config)
% Reset hpc configurations
set(hpc_config, cur_hpc_config);
end
