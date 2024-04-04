function  [tmp_generated,data_range,update_runids,grid_size,jd]=...
    convert_to_tmp_files(run_files,sqw_file,pix_db_range,grid_size_in,...
    accumulate_tmp,keep_parallel_pool)
% CONVERT_TO_TMP_FILES takes cellarray of rundata files and converts them
% into tmp files, intended to be combined into single sqw file.
%
% Reuses existing tmp files if found them as target and identified them as
% acceptable:
% Inputs:
% run_files -- cellarray of rundata classes to be converted into tmp files
%              (tmp files are sqw files, build from single nxspe file)
% sqw_file  -- the name of the final sqw file the tmp files are intended to
%              combine into. Used in reporting errors and warning only.
% pix_db_range
%           -- 2x4 array of the ranges to rebin pixels on. This is the grid
%              common between all tmp files to allow them to be combined
%              together.
% grid_size_in
%           -- Common grid (number of bins in each direction) each tmp file
%              should contain.
% accumulate_tmp
%           -- true or false depending on if the routine is used for
%              accumulation or generation. If true and existing tmp files
%              are found in generation mode, warning about these files is
%              issues.
% keep_parallel_pool
%           -- if true and tmp files generation is done in parallel, return
%              parallel pool for further usage.
% Outputs:
% tmp_generated
%           -- cellarray of names of generated or exisging tmp files.
% data_range-- Array of actual pixel ranges (2x9 at the moment), containing
%              actual min/max ranges of PixedlData values.
% grid_size -- Actual grid size used to bin pixels for tmp files. Always
%              equal to grid_size_in?
% jd        -- if keep_parallel_pool is true and tmp files were generated
%              in parallel, initialized and running instance of parallel
%              pool for further usage.

%
% if further operations are necessary to perform with generated tmp files,
% keep parallel pool running to save time on restarting it.

log_level           = get(hor_config,'log_level');
use_separate_matlab = get(hpc_config,'build_sqw_in_parallel');
num_matlab_sessions = get(parallel_config,'parallel_workers_number');

% build names for tmp files to generate
spe_file = cellfun(@(x)(x.loader.file_name),run_files,...
    'UniformOutput',false);
tmp_files=gen_tmp_filenames(spe_file,sqw_file);
tmp_generated = tmp_files;

data_range = [];
[f_valid_exist,img_ranges,data_ranges] = cellfun(@(fn)(check_tmp_files_range(fn,grid_size_in)),...
    tmp_files,'UniformOutput',false);
f_valid_exist = [f_valid_exist{:}];
if any(f_valid_exist)
    img_ranges = img_ranges(f_valid_exist);
    data_ranges= data_ranges(f_valid_exist);
    file_ranges_equal = cellfun(@(x)(all(abs(x(:)-img_ranges{1}(:)))<eps('double')),img_ranges);
    if all(file_ranges_equal) % use existing tmp files.
        if is_range_wider(img_ranges{1},pix_db_range)
            if ~accumulate_tmp
                warning('HORACE:valid_tmp_files_exist',['\n', ...
                    '*** There are %d previously generated tmp files present while generating %d tmp files for sqw file: %s.\n'...
                    '    Producing only new tmp files.\n'...
                    '    Delete all existing tmp files to avoid reusing them.\n'], ...
                    sum(f_valid_exist),numel(tmp_files),sqw_file)
            end
            % Change existing binning range to coincide with range found in
            % tmp files
            pix_db_range = img_ranges{1};
            data_range = data_ranges{1};
            for i=2:numel(data_ranges)
                data_range = minmax_ranges(data_range,data_ranges{i});
            end
            run_files  = run_files(~f_valid_exist);
            tmp_files  = tmp_files(~f_valid_exist);
            if isempty(run_files)
                grid_size = grid_size_in;
                update_runids= false;
                jd = [];
                return;
            end
        end
    end
end

nt=bigtic();
%write_banner=true;

if use_separate_matlab
    %
    % name parallel job by sqw file name
    [~,fn] = fileparts(sqw_file);
    if numel(fn) > 8
        fn = fn(1:8);
    end
    %
    job_name = ['gen_sqw_',fn];
    %
    jd = JobDispatcher(job_name);

    % aggregate the conversion parameters into array of structures,
    % suitable for splitting jobs between workers
    [common_par,loop_par]=gen_sqw_files_job.pack_job_pars(run_files',tmp_files,...
        grid_size_in,pix_db_range);
    %
    [outputs,n_failed,~,jd] = jd.start_job('gen_sqw_files_job',...
        common_par,loop_par,true,num_matlab_sessions,keep_parallel_pool);
    %
    if n_failed == 0
        outputs   = outputs{1};
        grid_size = outputs.grid_size;
        data_range1 = outputs.data_range;
        update_runids =outputs.update_runid;
    else
        jd.display_fail_job_results(outputs,n_failed,num_matlab_sessions,'GEN_SQW:runtime_error');
    end
    if ~keep_parallel_pool % clear job dispatcher
        jd = [];
    end
else
    jd = [];
    %---------------------------------------------------------------------
    % serial rundata to sqw transformation
    % equivalent of:
    %[grid_size,pix_range] = rundata_write_to_sqw (run_files,tmp_file,...
    %    grid_size_in,pix_range_in,instrument,sample,write_banner,opt);
    %
    % make it look like a parallel transformation. A bit less
    % effective but much easier to identify problem with
    % failing parallel job

    [grid_size,data_range1,update_runids]=gen_sqw_files_job.runfiles_to_sqw(run_files,tmp_files,...
        grid_size_in,pix_db_range,true);
    %---------------------------------------------------------------------
end

data_range = minmax_ranges(data_range,data_range1);


if log_level>-1
    disp('--------------------------------------------------------------------------------')
    bigtoc(nt,'Time to create all temporary sqw files:',log_level);
    % Create single sqw file combining all intermediate sqw files
    disp('--------------------------------------------------------------------------------')
end

end
%--------------------------------------------------------------------------
function [present_and_valid,img_range,data_range] = check_tmp_files_range(tmp_file,grid_size_in)
% Verify if the tmp files are present and their binning ranges are the same
% as requested by input parameters
if ~is_file(tmp_file)
    present_and_valid  = false;
    img_range = [];
    data_range =[];
    return;
end


ldr = sqw_formats_factory.instance().get_loader(tmp_file);

img_md    = ldr.get_dnd_metadata();
grid_size = img_md.axes.nbins_all_dims;
err = abs(grid_size-grid_size_in)>eps('single');
present_and_valid = ~any(err(:));
if present_and_valid
    img_range = img_md.img_range;
    data_range = ldr.get_data_range();
else
    data_range = [];
    img_range  = [];
end
end
