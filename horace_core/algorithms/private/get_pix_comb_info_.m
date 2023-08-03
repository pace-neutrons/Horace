function  [sqw_sum_struc,img_range,data_range,job_disp]=get_pix_comb_info_(infiles, ...
    data_range,job_disp, ...
    allow_equal_headers,keep_runid)
% The part of write_nsqw_to_sqw algorithm, responsible for preparing write
% pix operation
%
% It analyses all contributed headers, runs combine headers job and build
% main sqw file structure, including everything but writing pixels
% themselves.
% Assigns to sqw object structure pix field pix_combine_infor class,
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
%             except pix containing pix_combine_info class

combine_in_parallel = ~isempty(job_disp);
hor_log_level = get(hor_config,'log_level');


% Check that the input files all exist and give warning if the output files overwrite the input files.
% ----------------------------------------------------------------------------------------------------
% Convert to cell array of strings if single file name or array of strings
% is provided.
if istext(infiles)
    infiles=cellstr(infiles);
end

% Check input files exist
nfiles=length(infiles);
if ~all(cellfun(@is_file, infiles))
    exst = cellfun(@is_file, infiles);
    error('HORACE:write_nsqw_to_sqw:invalid_argument',...
        'Can not find files: %s ',infiles{exst})
end

% *** Check output file can be opened
% *** Check that output file and input files do not coincide
% *** Check do not repeat an input file name
% *** Check they are all sqw files


% Read header information from files, and check consistency
% ---------------------------------------------------------
% At present we require that all detector info is the same for all files, and each input file contains only one spe file
if hor_log_level>-1
    disp(' ')
    disp('Reading header(s) of input file(s) and checking consistency...')
end

%[main_header,header,datahdr,pos_npixstart,pos_pixstart,npixtot,det,ldrs]
[~,experiments_from_files,datahdr,pos_npixstart,pos_pixstart,npixtot,det,ldrs] = ...
    accumulate_headers_job.read_input_headers(infiles);
undef = data_range == PixelDataBase.EMPTY_RANGE;
if any(undef(:))
    data_range = pix_combine_info.recalc_data_range_from_loaders(ldrs,keep_runid);
end

% check the consistency of image headers as this is the grid where pixels
% are binned on and they have to be binned on the same grid
% We must have same data information for transforming pixels coordinates to image coordinates
img_range=datahdr{1}.img_range;
proj = datahdr{1}.proj;
for i=2:nfiles
    loc_range = datahdr{i}.img_range;
    if ~equal_to_tol(proj,datahdr{i}.proj,'tol',4*eps('single'))
        error('HORACE:algorithms:invalid_arguments',[...
            'The image projection for contributing sqw/tmp files have to be the same.\n ' ...
            'the projection for file N%d, name: %s different from the projection for the first contributing file %s\n'],...
            i,ldrs{i}.full_filename,ldrs{1}.full_filename);
    end
    if any(abs(img_range(:)-loc_range(:))) > 4*eps('single')
        error('HORACE:algorithms:invalid_arguments',[...
            'The binning ranges for all contributing sqw/tmp files have to be the same.\n ' ...
            'Range for file N%d, name: %s different from the range of the first contributing file: %s\n' ...
            ' *** min1: %s min%d: %s\,' ...
            ' *** max1: %s max%d: %s\n'], ...
            i,ldrs{i}.full_filename,ldrs{1}.full_filename, ...
            mat2str(img_range(1,:)),i,mat2str(loc_range(1,:)), ...
            mat2str(img_range(2,:)),i,mat2str(loc_range(2,:)))
    end

    % define total img range as minmax of contributing ranges to
    % avoid round-off errors
    img_range=minmax_ranges(img_range,loc_range);
end

% Check consistency:
% At present, we insist that the contributing spe data are distinct in that:
%   - filename, efix, psi, omega, dpsi, gl, gs cannot all be equal for two spe data input
%   - emode, lattice parameters, u, v, sample must be the same for all spe data input
[exper_combined,nspe] = Experiment.combine_experiments(experiments_from_files,allow_equal_headers,keep_runid);





%  Build combined header
nfiles_tot=sum(nspe);
mhc = main_header_cl('nfiles',nfiles_tot);

if isa(datahdr{1},'dnd_metadata') % have to be all the same and it
    % should have been checked at previous stages
    ab = datahdr{1}.axes;
    proj = datahdr{1}.proj;
else
    ab = ortho_axes.get_from_old_data(datahdr{1});
    proj = ortho_proj.get_from_old_data(datahdr{1});
end
sqw_data = DnDBase.dnd(ab,proj);
sqw_data.filename=mhc.filename;
sqw_data.filepath=mhc.filepath;
sqw_data.title=mhc.title;

% Now read in binning information
% ---------------------------------
% We did not read in the arrays s, e, npix from the files because if have a 50^4 grid then the size of the three
% arrays is is total 24*50^4 bytes = 150MB. Firstly, we cannot afford to read all of these arrays as it would
% require too much RAM (30GB if 200 spe files); also if we just want to check the consistency of the header information
% in the files first we do not want to spend lots of time reading and accumulating the s,e,npix arrays. We can do
% that now, as we have checked the consistency.
if hor_log_level>-1
    disp(' ')
    disp('Reading and accumulating binning information of input file(s)...')
end

if combine_in_parallel
    %TODO:  check config for appropriate ways of combining the tmp and what
    %to do with cluster
    comb_using = config_store.instance().get_value('hpc_config','combine_sqw_using');
    if strcmp(comb_using,'mpi_code') % keep cluster running for combining procedure
        keep_workers_running = true;
    else
        keep_workers_running = false;
    end
    [common_par,loop_par] = accumulate_headers_job.pack_job_pars(ldrs);
    if isempty(job_disp)
        n_workers = config_store.instance().get_value('hpc_config','parallel_workers_number');
        [outputs,n_failed,~,job_disp]=job_disp.start_job(...
            'accumulate_headers_job',common_par,loop_par,true,n_workers,keep_workers_running );
    else
        [outputs,n_failed,~,job_disp]=job_disp.restart_job(...
            'accumulate_headers_job',common_par,loop_par,true,keep_workers_running );
        n_workers = job_disp.cluster.n_workers;
    end
    %
    if n_failed == 0
        s_accum = outputs{1}.s;
        e_accum = outputs{1}.e;
        npix_accum = outputs{1}.npix;
    else
        job_disp.display_fail_job_results(outputs,n_failed,n_workers, ...
            'HORACE:write_nsqw_to_sqw:runtime_error');
    end
else
    % read arrays and accumulate headers directly
    [s_accum,e_accum,npix_accum] = accumulate_headers_job.accumulate_headers(ldrs);
end
[s_accum,e_accum] = normalize_signal(s_accum,e_accum,npix_accum);
%
sqw_data.s=s_accum;
sqw_data.e=e_accum;
sqw_data.npix=uint64(npix_accum);

clear nopix

% Prepare writing to output file
% ---------------------------
if keep_runid
    run_label = 'nochange';
else
    keys = exper_combined.runid_map.keys;
    run_label=[keys{:}];
end
% if old_matlab
%     npix_cumsum = cumsum(double(sqw_data.npix(:)));
% else
%     npix_cumsum = cumsum(sqw_data.npix(:));
% end
%
% instead of the real pixels to place in target sqw file, place in pix field the
% information about the way to get the contributing pixels
pix = pix_combine_info(infiles,numel(sqw_data.npix),pos_npixstart,pos_pixstart,npixtot,run_label);
pix.data_range = data_range;

sqw_sum_struc= struct('main_header',mhc,'experiment_info',exper_combined,'detpar',det);
sqw_sum_struc.data = sqw_data;
sqw_sum_struc.pix = pix;