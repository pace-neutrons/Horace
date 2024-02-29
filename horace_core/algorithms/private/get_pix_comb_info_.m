function  [sqw_sum_struc,data_range,job_disp]=get_pix_comb_info_(infiles, ...
    data_range,job_disp, ...
    allow_equal_headers,keep_runid)
% The part of write_nsqw_to_sqw algorithm, responsible for preparing write
% pix operation
%
% It analyses all contributed headers, runs combine headers job and build
% main sqw file structure, including everything but writing pixels
% themselves.
% Assigns to sqw object structure pix field pixfile_combine_info class,
% containing information about source pixels locations and target pixel
% location to write
%
% Inputs:
% infiles  -- cellarray of tmp sqw files to process
% job_disp -- the instance of initialized job dispatcher class,
%             connected to running cluster job if the algorithm is supposed
%             to be run in parallel. If this value is not empty, the
%             combine_headers job will be performed in parallel using the
%             cluster, connected to job_disp
% combine_in_parallel
%          -- if true, the combine_header job will be performed
%             in parallel. If job_disp is empty, new cluster job instance
%             will be launched.
% allow_equal_headers
%          -- if true, check for different headers is not run,
%             and the runs with the same parameters are allowed
% keep_runid
%          -- if true, the runid-s attached to each experiment are left
%             as they are. If false, all run numbers are redefined to be
%             from 1-number of runs.
% returns:
% sqw_sum_struc
%          -- the structure of sqw object with all sqw fields filled in
%             except pix containing pixfile_combine_info class

hor_log_level = get(hor_config,'log_level');


% Check that the input files all exist and give warning if the output files overwrite the input files.
% ----------------------------------------------------------------------------------------------------
% Convert to cell array of strings if single file name or array of strings
% is provided.
if istext(infiles)
    infiles=cellstr(infiles);
end

% Check input files exist
if ~all(cellfun(@isfile, infiles))
    exst = cellfun(@isfile, infiles);
    error('HORACE:algorithms:invalid_argument',...
        'Can not find files: %s ',infiles{~exst})
end

% Read header information from files, and check consistency
% ---------------------------------------------------------
% At present we require that all detector info is the same for all files, and each input file contains only one spe file
if hor_log_level>-1
    disp(' ')
    disp('Reading header(s) of input file(s) and checking consistency...')
end

%[main_header,header,datahdr,pos_npixstart,pos_pixstart,npixtot,det,ldrs]
[~,experiments_from_files,img_hdrs,pos_npixstart,pos_pixstart,npixtot,ldrs] = ...
    accumulate_headers_job.read_input_headers(infiles);
undef = data_range == PixelDataBase.EMPTY_RANGE;
if any(undef(:))
    data_range = pixfile_combine_info.recalc_data_range_from_loaders(ldrs,keep_runid);
end

[dnd_data,exper_combined,mhc] = combine_exper_and_img_( ...
    experiments_from_files,img_hdrs,ldrs,allow_equal_headers,keep_runid, ...
    job_disp,hor_log_level);


% Prepare writing to output file
% ---------------------------
if keep_runid
    run_label = 'nochange';
else
    keys = exper_combined.runid_map.keys;
    run_label=[keys{:}];
end
%
% instead of the real pixels to place in target sqw file, place in pix field the
% information about the way to get the contributing pixels
pix = pixfile_combine_info(infiles,numel(dnd_data.npix),npixtot, ...
    pos_npixstart,pos_pixstart,run_label);
pix.data_range = data_range;

sqw_sum_struc= struct('main_header',mhc,'experiment_info',exper_combined,'detpar',[]);
sqw_sum_struc.data = dnd_data;
sqw_sum_struc.pix  = pix;