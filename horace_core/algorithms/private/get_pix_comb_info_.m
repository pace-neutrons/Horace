function  [data_sum,img_range,job_disp]=get_pix_comb_info_(infiles, ...
    data_range,job_disp, ...
    allow_equal_headers,keep_runid,drop_subzone_headers)
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
% infiles  -- cellarry of tmp sqw files to process
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
%          -- if true, the runid-s attached to each experient are left
%             as they are. If false, all run numbers are redefined to be
%             from 1-number of runs.
% drop_subzone_headers
%          -- currently depricated. Will be removed in the future
%

combine_in_parallel = ~isempty(job_disp);
hor_log_level = get(hor_config,'log_level');


% Check that the input files all exist and give warning if the output files overwrite the input files.
% ----------------------------------------------------------------------------------------------------
% Convert to cell array of strings if necessary
if ~iscellstr(infiles)
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
[~,header,datahdr,pos_npixstart,pos_pixstart,npixtot,det,ldrs] = ...
    accumulate_headers_job.read_input_headers(infiles);
undef = data_range == PixelDataBase.EMPTY_RANGE;
if any(undef(:))
    data_range = pix_combine_info.recalc_data_range_from_loaders(ldrs);
    data_range_calculated = true;
else
    data_range_calculated = false;
end

% Check consistency:
% At present, we insist that the contributing spe data are distinct in that:
%   - filename, efix, psi, omega, dpsi, gl, gs cannot all be equal for two spe data input
%   - emode, lattice parameters, u, v, sample must be the same for all spe data input
% We must have same data information for alatt, angdeg, uoffset, u_to_rlu, ulen, pax, iint, p
% This guarantees that the pixels are independent (the data may be the same if an spe file name is repeated, but
% it is assigned a different Q, and is in the spirit of independence)
[header_combined,nspe] = Experiment.combine_experiments(header,allow_equal_headers,drop_subzone_headers);
%[header_combined,nspe] = sqw_header.header_combine(header,allow_equal_headers,drop_subzone_headers);


img_range=datahdr{1}.img_range;
for i=2:nfiles
    img_range=[min(img_range(1,:),datahdr{i}.img_range(1,:));max(img_range(2,:),datahdr{i}.img_range(2,:))];
end
if data_range_calculated
    %TODO: THIS SHOULD WORK BUT IT DOES NOT. What is the problem?
    %     if any(abs(pix_range(:)-img_range(:))> eps(single(1)))
    %         error('HORACE:write_nsqw_to_sqw:runtime_error', ...
    %             'Calculated pix range is different from calculated img_range -- this should not happen')
    %     end
end


%  Build combined header
if drop_subzone_headers
    nfiles_2keep = nspe>0;
    nspec = nspe(nfiles_2keep);
    nfiles_tot=sum(nspec);
else
    nfiles_tot=sum(nspe);
end
mhc = main_header_cl('nfiles',nfiles_tot);

if isa(datahdr{1},'dnd_metadata')
    ab = datahdr{1}.axes;
    proj = datahdr{1}.proj;
else
    ab = axes_block.get_from_old_data(datahdr{1});
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
if drop_subzone_headers || keep_runid
    run_label = 'nochange';
else
    run_label=cumsum(nspe(1:end));
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

data_sum= struct('main_header',mhc,'experiment_info',[],'detpar',det);
data_sum.data = sqw_data;
data_sum.experiment_info = header_combined;
data_sum.pix = pix;