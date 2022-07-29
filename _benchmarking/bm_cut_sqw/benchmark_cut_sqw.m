function benchmark_cut_sqw(nDims,nData,objType,nProcs,eRange,filename,contiguous)
%BENCHMARK_CUT_SQW This function generates cuts from sqw or dnd objects and
%uses the profiler to generate a csv file of timing data.
%BENCHMARK_CUT_SQW is used in 2 ways:
%                   - Called from the test_bm_cut_sqw... functions that
%                   supply BENCHMARK_CUT_SQW with default "use-case"
%                   parameters
%                   - Called directly from command line to run a "custom"
%                   benchmark using parameters supplied by the user
%For the "custom" benchmarks case, the input parameters must be as follows:
% nDims: dimensioon of cut, must 1D, 2D or 3D
% dataSource: must be the filename of an sqw object in the bm_cut_sqw
% folder of a integer corresponding to the amount of data/pixels wanted
% i.e.

%% Setup nprocs and other config info with hpc_config() (save intiial config details for later)

hpc = hpc_config();
cur_hpc_config = hpc.get_data_to_store();

% remove configurations from memory. Ensure only stored configurat  ions are
% stored
clear config_store;

% Set hpc config for benchmarks
if nProcs > 1
%     hpc.cut_parallel = true for future implementation
%     hpc.parallel_workers_number = nProcs;
    warning("HORACE:benchmark_cut_sqw:not_implemented",...
        "cut_parallel does not yet exist, setting nProcs to 0")
    nProcs=0;
else
%     hpc.cut_parallel=false
end

%% set projection and binning info, start profiler and call cut_sqw

proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';
%Set pixel bins
switch nDims
    case 1
        p1_bin=[-3,0.05,3];p2_bin=[1.9,2.1];p3_bin=[-0.1,0.1];
    case 2
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];
    case 3
        p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-0.1,0.1];
    otherwise
        error("HORACE:benchmark_cut_sqw:invalid_argument",...
            "nDims is the dimensions of the cut: must be 1, 2 or 3")
end

% Set energy bins
if isa(eRange, 'string')
    switch true
        case eRange == "large" && nDims == 1
            p4_bin=[0,700];
        case eRange == "medium" && nDims == 1
            p4_bin=[0,350];
        case eRange == "small" && nDims == 1
            p4_bin=[0,175];
        case eRange == "large" && (nDims == 2 || nDims == 3)
            p4_bin=[0,16,700];
        case eRange == "medium" && (nDims == 2 || nDims == 3)
            p4_bin=[0,16,350];
        case eRange == "small" && (nDims == 2 || nDims == 3)
            p4_bin=[0,16,175];
        otherwise
            error("HORACE:benchmark_cut_sqw:invalid_argument",...
                "if using a string for eRange, must be either ""small"", ""medium"" or ""large""")
    end
elseif isa(eRange,'double')
    switch true
        case (numel(eRange) == 2 || numel(eRange) == 4) && nDims == 1
            p4_bin = eRange;
        case (numel(eRange) == 1 || numel(eRange) == 3) && (nDims == 2 || nDims == 3)
            p4_bin = eRange;
        otherwise
            error("HORACE:benchmark_cut_sqw:invalid_argument",...
                "if using an array of doubles for eRange, length of the" + ...
                " array must be from 1 to 4, see help sqw/cut for more details")
    end
else
    error("HORACE:benchmark_cut_sqw:invalid_argument",...
                "eRange must be either an array of doubles or a string")
end

% Check if the "contiguous", has been set to true (will do X contiguous
% cuts)
profile on
if isa(nData, 'char')
    if ~contiguous
        switch objType
            case "sqw"
                sqw_cut = cut_sqw(nData,proj,p1_bin,p2_bin,p3_bin,p4_bin);
            case "dnd"
                dnd_cut = cut_sqw(nData,proj,p1_bin,p2_bin,p3_bin,p4_bin, '-nopix');
            otherwise
                error("HORACE:benchmark_cut_sqw:invalid_argument",...
                    "objType must be sqw or dnd")
        end
    else
        switch objType
            case "sqw"
                for j=0:4
                    p1_bin = [j-3,0.5,j];
                    sqw_cut = cut_sqw(nData,proj,p1_bin,p2_bin,p3_bin,p4_bin);
                end
            case "dnd"
                for j=0:4
                    p1_bin = [j-3,0.5,j];
                    dnd_cut = cut_sqw(nData,proj,p1_bin,p2_bin,p3_bin,p4_bin, '-nopix');
                end
            otherwise
                error("HORACE:benchmark_cut_sqw:invalid_argument",...
                    "objType must be sqw or dnd")
        end
    end
elseif isa(nData,'double')
    switch objType
        case "sqw"
            sqw_obj = gen_bm_cut_data(nData);
            sqw_cut = cut_sqw(sqw_obj,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        case "dnd"
            dnd_obj = gen_bm_cut_data(nData);
            dnd_cut = cut_sqw(dnd_obj,proj,p1_bin,p2_bin,p3_bin,p4_bin,'-nopix');
        otherwise
            error("HORACE:benchmark_cut_sqw:invalid_argument",...
                    "objType must be sqw or dnd")
    end
else
    error("HORACE:benchmark_cut_sqw:invalid_argument",...
                    "dataSource must be an integer or an exisiting" + ...
                    " sqw filename")
end

%% dump benchmark info (setup seperate dumps function for differnet type of dumps: html, all text(profsave), csv, just bm time...
prof_result = profile('info');
prof_folder = fullfile(fileparts(fileparts(mfilename('fullpath')...
                )),'bm_cut_sqw');
dump_profile(prof_result,fullfile(prof_folder,filename));

% % Create cleanup object (*** MUST BE DONE BEFORE ANY CHANGES TO CONFIGURATIONS)
cleanup_obj = onCleanup(@()benchmark_cut_sqw_cleanup(cur_hpc_config));
end

function benchmark_cut_sqw_cleanup(cur_hpc_config)
% Reset hpc configurations
set(hpc_config, cur_hpc_config);
% delete(string(sqw_file))
end
